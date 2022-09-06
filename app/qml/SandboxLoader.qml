/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.12
import org.kde.kirigami 2.11 as Kirigami
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils

Item {
    id: mItem
    Layout.fillWidth: true
    Layout.fillHeight: true
    property var pageTitle
    property var pageUrl: sandboxURL
    property var pageId
    property var navMode: "vMouse"
    property bool vMouseEnabled: false
    property int currentScrollSpeed: Aura.GlobalSettings.virtualScrollSpeed
    signal returnFocus

    Connections {
        target: root

        onBlurFieldRequested: {
            if(mItem.visible) {
                webView.runJavaScript('document.activeElement.blur()');
            }
        }
        onMouseActivationRequested: {
            if(mItem.visible) {
                vMouseEnabled = true
                mouseCursor.forceActiveFocus();
            }
        }
        onMouseDeActivationRequested: {
            if(mItem.visible) {
                vMouseEnabled = false
            }
        }
        onIgnoreInputRequested: {
            if(mItem.visible){
                webView.forceActiveFocus()
            }
        }
    }

    onPageUrlChanged: {
        webView.url = pageUrl
    }

    Component.onCompleted: {
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

        TopBarSandbox{
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

                onDownloadRequested: {
                    download.accept()
                    download.pause()
                    var downloadFileName = download.path.split('/').pop(-1)
                    interactionBar.setSource("DownloadRequest.qml")
                    interactionBar.interactionItem.download = download
                    interactionBar.interactionItem.actionsVisible = true
                    interactionBar.interactionItem.downloadName = downloadFileName
                    interactionBar.isRequested = true
                }

                onDownloadFinished: {
                    console.log("In download finished")
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

                onDownloadRequested: {
                    download.accept()
                    download.pause()
                    var downloadFileName = download.path.split('/').pop(-1)
                    interactionBar.setSource("DownloadRequest.qml")
                    interactionBar.interactionItem.download = download
                    interactionBar.interactionItem.actionsVisible = true
                    interactionBar.interactionItem.downloadName = downloadFileName
                    interactionBar.isRequested = true
                }

                onDownloadFinished: {
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

            userScripts: [
                WebEngineScript {
                    injectionPoint: WebEngineScript.DocumentCreation
                    name: "QWebChannel"
                    worldId: WebEngineScript.MainWorld
                    sourceUrl: Qt.resolvedUrl("./code/qwebchannel.js")
                },
                WebEngineScript {
                    injectionPoint: WebEngineScript.DocumentReady
                    name: "QWebInput"
                    worldId: WebEngineScript.MainWorld
                    runOnSubframes: true
                    sourceUrl: Qt.resolvedUrl("./code/qwebinput.js")
                }
            ]

            onFeaturePermissionRequested: {
                interactionBar.setSource("FeatureRequest.qml")
                interactionBar.interactionItem.securityOrigin = securityOrigin;
                interactionBar.interactionItem.requestedFeature = feature;
                interactionBar.isRequested = true;
            }

            onLoadingChanged: {
                vMouseEnabled = true;
                Aura.GlobalSettings.focusOffVKeyboard();
                mouseCursor.forceActiveFocus();
            }

            settings {
                focusOnNavigationEnabled: false
                pluginsEnabled: true
                showScrollBars: false
            }

            onFullScreenRequested: {
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

            Action {
                shortcut: "Left"
                enabled: vMouseEnabled && mItem.visible && navMode == "vMouse"
                onTriggered: {
                    Utils.navigateKeyLeft()
                }
            }

            Action {
                shortcut: "Right"
                enabled: vMouseEnabled && mItem.visible && navMode == "vMouse"
                onTriggered: {
                    Utils.navigateKeyRight()
                }
            }

            Action {
                shortcut: "Up"
                enabled: vMouseEnabled && mItem.visible && navMode == "vMouse"
                onTriggered: {
                    Utils.navigateKeyUp()
                }
            }

            Action {
                shortcut: "Down"
                enabled: vMouseEnabled && mItem.visible && navMode == "vMouse"
                onTriggered: {
                    Utils.navigateKeyDown()
                }
            }

            Action {
                shortcut: "Return"
                enabled: vMouseEnabled && mItem.visible && navMode == "vMouse"
                onTriggered: {
                    Cursor.click();
                }
            }

            onJavaScriptConsoleMessage: {
                try {
                    var jsonMessage = JSON.parse(message);
                } catch(err) {
                    jsonMessage = JSON.parse('{"className": "None", "id": "None", "inputFocus": "None"}');
                }
                myObject.cName = jsonMessage.className
                pageId = jsonMessage.id
                if(jsonMessage.inputFocus == "GotInput"){
                    Aura.GlobalSettings.focusOnVKeyboard();
                }
            }
        }

        Rectangle {
            id: mouseCursor
            width: Kirigami.Units.gridUnit * 1.5
            height: Kirigami.Units.gridUnit * 1.5
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
    }
}
