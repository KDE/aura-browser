/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtWebChannel 1.0
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.12
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils
import QtWebEngine
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: mItem
    Layout.fillWidth: true
    Layout.fillHeight: true
    property var pageTitle
    property var pageUrl
    property bool toRemove: false
    property var pageId
    property var navMode: "vMouse"
    property bool vMouseEnabled: false
    property int currentScrollSpeed: Aura.GlobalSettings.virtualScrollSpeed
    signal returnFocus

    Rectangle {
        id: mouseCursor
        width: (Kirigami.Units.gridUnit * 1.5) * Aura.GlobalSettings.virtualMouseSize
        height: (Kirigami.Units.gridUnit * 1.5) * Aura.GlobalSettings.virtualMouseSize
        radius: 100
        border.width: Kirigami.Units.smallSpacing
        border.color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
        color: Qt.rgba(Kirigami.Theme.linkColor.r, Kirigami.Theme.linkColor.g, Kirigami.Theme.linkColor.b, 0.8)
        x: Cursor.pos.x
        y: Cursor.pos.y
        z: 1002
        visible: Cursor.visible
        enabled: vMouseEnabled
    }

    Connections {
        target: root

        function onBlurFieldRequested() {
            if(mItem.visible) {
                webView.runJavaScript('document.activeElement.blur()');
            }
        }
        function onMouseActivationRequested() {
            if(mItem.visible) {
                vMouseEnabled = true
                mouseCursor.forceActiveFocus();
            }
        }
        function onMouseDeActivationRequested() {
            if(mItem.visible) {
                vMouseEnabled = false
            }
        }
        function onIgnoreInputRequested() {
            if(mItem.visible){
                webView.forceActiveFocus()
            }
        }
    }


    onPageUrlChanged: {
        webView.url = pageUrl
    }

    BookmarkManager{
        id: bookmarkTabManager
        model: bookmarksModel
        genericModel: bookmarksModel
    }

    onToRemoveChanged: {
        removeFromTabView(parent.currentIndex);
        mItem.destroy()
    }

    Component.onCompleted: {
        keyFilter.startFilter();
        var scriptFoo = WebEngine.script()
        scriptFoo.injectionPoint = WebEngineScript.DocumentCreation
        scriptFoo.name = "QWebChannel"
        scriptFoo.worldId = WebEngineScript.MainWorld
        scriptFoo.sourceUrl = Qt.resolvedUrl("./code/qwebchannel.js")
        webView.userScripts.insert(scriptFoo)

        var scriptRoo = WebEngine.script()  
        scriptRoo.injectionPoint = WebEngineScript.DocumentReady
        scriptRoo.name = "QWebInput"
        scriptRoo.worldId = WebEngineScript.MainWorld
        scriptRoo.runOnSubframes = true
        scriptRoo.sourceUrl = Qt.resolvedUrl("./code/qwebinput.js")

        webView.userScripts.insert(scriptRoo)
        webChannel.registerObject("foo", myObject)
    }

    QtObject {
        id: myObject
        objectName: "myObject"
        property string tInput: "";
        property string cName: "";
    }

    FocusScope {
        anchors.fill: parent

        TopBar{
            id: topBarPage
            anchors.top: parent.top
        }

        RequestHandler {
            id: interactionBar
            anchors.top: topBarPage.bottom
            z: 1001
        }

        WebChannel {
            id: webChannel
        }

        WebEngineView {
            id: webView
            anchors.top: interactionBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            focus: true
            objectName: "webengineview"
            webChannel: webChannel
            profile: Aura.GlobalSettings.adblockEnabled == 1 ? adblockProfile : defaultProfile

            Connections {
                target: adblockProfile

                function onDownloadRequested(download) {
                    download.accept()
                    download.pause()
                    var downloadFileName = download.path.split('/').pop(-1)
                    interactionBar.setSource("DownloadRequest.qml")
                    interactionBar.interactionItem.download = download
                    interactionBar.interactionItem.actionsVisible = true
                    interactionBar.interactionItem.downloadName = downloadFileName
                    interactionBar.isRequested = true
                }

                function onDownloadFinished(download) {
                    if (download.state === WebEngineDownloadItem.DownloadCompleted) {
                        interactionBar.interactionItem.actionsVisible = false
                        interactionBar.interactionItem.isDownloading = false
                        interactionBar.interactionItem.messageText = i18n("Download finished")
                    }
                    else if (download.state === WebEngineDownloadItem.DownloadInterrupted) {
                        interactionBar.interactionItem.actionsVisible = false
                        interactionBar.interactionItem.isDownloading = false
                        interactionBar.interactionItem.messageText = i18n("Download failed: %1", download.interruptReason)
                    }
                    else if (download.state === WebEngineDownloadItem.DownloadCancelled) {
                        interactionBar.interactionItem.isDownloading = false
                    }
                }
            }

            WebEngineProfile {
                id: defaultProfile
                httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36"

                onDownloadRequested: function(download) {
                    download.accept()
                    download.pause()
                    var downloadFileName = download.path.split('/').pop(-1)
                    interactionBar.setSource("DownloadRequest.qml")
                    interactionBar.interactionItem.download = download
                    interactionBar.interactionItem.actionsVisible = true
                    interactionBar.interactionItem.downloadName = downloadFileName
                    interactionBar.isRequested = true
                }

                onDownloadFinished: function(download) {
                    if (download.state === WebEngineDownloadItem.DownloadCompleted) {
                        interactionBar.interactionItem.actionsVisible = false
                        interactionBar.interactionItem.isDownloading = false
                        interactionBar.interactionItem.messageText = i18n("Download finished")
                    }
                    else if (download.state === WebEngineDownloadItem.DownloadInterrupted) {
                        interactionBar.interactionItem.actionsVisible = false
                        interactionBar.interactionItem.isDownloading = false
                        interactionBar.interactionItem.messageText = i18n("Download failed: %1", download.interruptReason)
                    }
                    else if (download.state === WebEngineDownloadItem.DownloadCancelled) {
                        interactionBar.interactionItem.isDownloading = false
                    }
                }
            }

            onFeaturePermissionRequested: function(securityOrigin, feature) {
                interactionBar.setSource("FeatureRequest.qml")
                interactionBar.interactionItem.securityOrigin = securityOrigin;
                interactionBar.interactionItem.requestedFeature = feature;
                interactionBar.isRequested = true;
            }

            onLoadingChanged: function(loadingInfo) {
                if(loadingInfo.status == WebEngineView.LoadSucceededStatus){
                    webView.runJavaScript("document.title", function(title){
                        pageTitle = title
                        Utils.insertRecentToStorage(webView.url, pageTitle)
                    });
                } else {
                    console.log("Loading..")
                }

                vMouseEnabled = true;
                Aura.GlobalSettings.focusOffVKeyboard();
                mouseCursor.forceActiveFocus();
            }

            settings {
                focusOnNavigationEnabled: false
                pluginsEnabled: true
                showScrollBars: false
            }

            onFullScreenRequested: function(request) {
                request.accept()                
                if (root.visibility !== Window.FullScreen) {
                    topBarPage.viewFullscreenMode = true
                    root.showFullScreen()
                } else if (root.visibility == Window.FullScreen && !topBarPage.viewFullscreenMode){
                    topBarPage.viewFullscreenMode = true
                } else {
                    topBarPage.viewFullscreenMode = false
                }
            }

            onNewWindowRequested: function(req) {
                createTab(req.requestedUrl)
            }

            onJavaScriptConsoleMessage: function(message, lineNumber, sourceID) {
                try {
                    var jsonMessage = JSON.parse(message);
                } catch(err) {
                    jsonMessage = JSON.parse('{"className": "None", "id": "None", "inputFocus": "None"}');
                }
                if (jsonMessage.hasOwnProperty('className')) {
                    myObject.cName = jsonMessage.className
                    pageId = jsonMessage.id
                    if(jsonMessage.inputFocus == "GotInput"){
                        Aura.GlobalSettings.focusOnVKeyboard();
                    }
                }
            }
        }

        LocalURLSearchHandler{
            id: localUrlEntryDrawer
        }
    }
}
