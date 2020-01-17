/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Window 2.10
import QtWebEngine 1.8
import QtWebChannel 1.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.0
import org.kde.kirigami 2.11 as Kirigami
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils
import QtQuick.VirtualKeyboard 2.5

Item {
    id: mItem
    Layout.fillWidth: true
    Layout.fillHeight: true
    property var pageTitle
    property var pageUrl
    property bool toRemove: false
    property var pageId
    property var currentContentHeight
    property var currentContentWidth
    property var navMode: "vMouse"
    signal flickDown
    signal flickUp

    onPageUrlChanged: {
        webView.url = pageUrl
    }

    onToRemoveChanged: {
        removeFromTabView(parent.currentIndex);
        mItem.destroy()
    }

    Component.onCompleted: {
        Cursor.setStep(15)
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

        WebChannel {
            id: webChannel
        }

        Flickable {
            id: flickable
            anchors.top: topBarPage.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ScrollBar.vertical: ScrollBar{
                width: Kirigami.Units.gridUnit * 1
                policy: flickable.contentHeight > flickable.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
            }

            onMovementEnded: {
                if(atYEnd){
                    //Try Fixing Parallax WebPage Scrolling
                    webView.runJavaScript('window.scrollTo(0,document.scrollingElement.scrollHeight);')
                    webView.runJavaScript('document.documentElement.scrollHeight;', function(e){
                        if(flickable.contentHeight < e){
                            flickable.contentHeight = e
                        };
                    })
                }
            }

            Connections {
                target: mItem
                onFlickUp:{
                    flickable.flick(0, -1000)
                }
                onFlickDown: {
                    flickable.flick(0, +1000)
                }
            }

            WebEngineView {
                id: webView
                anchors.fill: parent
                focus: true
                objectName: "webengineview"
                webChannel: webChannel

                profile {
                    httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36"
                }

                userScripts: [
                    WebEngineScript {
                        injectionPoint: WebEngineScript.DocumentCreation
                        name: "QWebChannel"
                        worldId: WebEngineScript.MainWorld
                        sourceUrl: Qt.resolvedUrl("./code/qwebchannel.js")
                    }
                ]

                onLoadingChanged: {
                    if(loadRequest.status == WebEngineView.LoadSucceededStatus){
                        webView.runJavaScript("document.title", function(title){
                            pageTitle = title
                            Utils.insertRecentToStorage(webView.url, pageTitle)
                        });

                        webView.runJavaScript('var element = document.getElementsByTagName("INPUT"); var index; for(var index = 0; index < element.length; index++) {element[index].onfocus = function(){console.log(JSON.stringify({"inputFocus": "GotInput", "className": document.activeElement.form.className, "id": document.activeElement.id}))}};')

                        flickable.contentHeight = 0;
                        flickable.contentWidth = flickable.width;

                        runJavaScript (
                                    "document.documentElement.scrollHeight;",
                                    function (actualPageHeight) {
                                        flickable.contentHeight = Math.max (
                                                    actualPageHeight, flickable.height);
                                        currentContentHeight = flickable.contentHeight
                                    });

                        runJavaScript (
                                    "document.documentElement.scrollWidth;",
                                    function (actualPageWidth) {
                                        flickable.contentWidth = Math.max (
                                                    actualPageWidth, flickable.width);
                                        currentContentWidth = flickable.contentWidth
                                    });
                        mouseCursor.forceActiveFocus()
                    } else {
                        console.log("Loading..")
                    }
                }

                settings {
                    focusOnNavigationEnabled: false
                    pluginsEnabled: true
                }

                onFullScreenRequested: {
                    request.accept()
                    if (root.visibility !== Window.FullScreen) {
                        root.showFullScreen()
                        flickable.contentHeight = flickable.height + topBarPage.height
                        flickable.contentWidth = flickable.width
                    }
                    else {
                        root.showNormal()
                        flickable.contentHeight = currentContentHeight
                        flickable.contentWidth = currentContentWidth
                    }
                }

                Action {
                    shortcut: "Left"
                    enabled: mItem.visible && navMode == "vMouse"
                    onTriggered: {
                        Utils.navigateKeyLeft()
                    }
                }

                Action {
                    shortcut: "Right"
                    enabled: mItem.visible && navMode == "vMouse"
                    onTriggered: {
                        Utils.navigateKeyRight()
                    }
                }

                Action {
                    shortcut: "Up"
                    enabled: mItem.visible && navMode == "vMouse"
                    onTriggered: {
                        Utils.navigateKeyUp()
                    }
                }

                Action {
                    shortcut: "Down"
                    enabled: mItem.visible && navMode == "vMouse"
                    onTriggered: {
                        Utils.navigateKeyDown()
                    }
                }

                Action {
                    shortcut: "Return"
                    enabled: mItem.visible && navMode == "vMouse"
                    onTriggered: {
                        Cursor.click();
                    }
                }

                onJavaScriptConsoleMessage: {
                    console.log(message)
                    var jsonMessage = JSON.parse(message);
                    myObject.cName = jsonMessage.className
                    pageId = jsonMessage.id
                    if(jsonMessage.inputFocus == "GotInput"){
                        inputDrawer.open()
                    }
                }
            }
        }

        Dialog {
            id: inputDrawer
            width: parent.width
            height: parent.height
            modal: false
            background: Rectangle{
                color: 'transparent'
            }

            onClosed: {
               webView.runJavaScript('document.activeElement.blur()');
            }

            Item {
                width: parent.width
                height: parent.height

                InputPanel {
                    id: inputPanel
                    y: parent.height - inputPanel.height
                    anchors.left: parent.left
                    anchors.right: parent.right

                    onActiveChanged: {
                        if(!active){
                            webView.runJavaScript('document.activeElement.blur()');
                            inputDrawer.close()
                        }
                    }
                }
            }
        }

        LocalURLSearchHandler{
            id: localUrlEntryDrawer
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
            visible: Cursor.visible
        }
    }
}
