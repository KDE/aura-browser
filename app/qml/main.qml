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

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtWebEngine 1.8
import QtQuick.Controls 2.12 as Controls
import QtQuick.LocalStorage 2.12
import org.kde.kirigami 2.11 as Kirigami
import "views" as Views
import "delegates" as Delegates
import "code/RecentStorage.js" as RecentStorage
import "code/BookmarkStorage.js" as BookmarkStorage
import "code/Utils.js" as Utils
import Aura 1.0 as Aura
import QtQuick.VirtualKeyboard 2.4
import QtQuick.VirtualKeyboard.Settings 2.4

Kirigami.AbstractApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Aura-Browser")
    property alias showStack: auraStack.currentIndex
    property int virtualMouseMoveSpeed: 10
    signal settingsTabRequested
    signal blurFieldRequested
    signal mouseActivationRequested
    signal mouseDeActivationRequested
    visibility: "Maximized"

    function switchToTab(index){
        auraStack.currentIndex = index
    }

    function removeFromTabView(index){
        tabBarViewModel.remove(index);
        auraStack.currentIndex = 0;
    }

    function removeTab(){
        auraStack.itemAt(tabsListView.currentIndex).toRemove = true;
    }

    function createTab(url){
        var gencolor = Utils.genRandomColor()
        var tcolor = gencolor.toString()
        var cpm = Qt.createComponent("WebLoader.qml");
        if (cpm.status == Component.Ready) {
            var tpm = cpm.createObject(auraStack, {pageUrl: url});
            tpm.pageUrl = url
            tabBarViewModel.append({"pageName": url, "rand_color": tcolor, "removable": true})
            showStack = auraStack.count - 1
        }
    }

    function prependStartPage(){
        var gencolor = Utils.genRandomColor()
        var tcolor = gencolor.toString()
        var spm = Qt.createComponent("StartPage.qml")
        if(spm.status == Component.Ready){
            var spmi = spm.createObject(auraStack, {});
            tabBarViewModel.append({"pageName": "Start Page", "rand_color": tcolor, "removable": false})
            showStack = auraStack.count - 1
        }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        id: gDrawer
        handleVisible: false

        onOpened:  {
            quitButton.forceActiveFocus();
        }

        Controls.Label {
            id: bblabl
            text: "Press 'esc' or the [←] Back button to close"
            Layout.alignment: Qt.AlignRight
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        Controls.Button {
            id: quitButton
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4

            background: Rectangle {
                color: quitButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.disabledTextColor
            }

            contentItem: RowLayout {
                Kirigami.Icon {
                    source: "window-close"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }

                Controls.Label {
                    Layout.fillWidth: true
                    text: "Quit"
                }
            }

            onClicked: {
                root.close();
            }

            Keys.onReturnPressed: {
                clicked()
            }
        }
    }

    ListModel {
        id: tabBarViewModel
    }

    ListModel {
        id: bookmarksModel
    }

    StackLayout {
        id: auraStack
        anchors.fill: parent
        currentIndex: tabsListView.currentIndex
    }

    Kirigami.OverlayDrawer {
        id: tabBarView
        width: parent.width
        height: parent.height / 3
        edge: Qt.TopEdge

        onOpened: {
            tabsListView.forceActiveFocus()
            auraStack.itemAt(auraStack.currentIndex).focus = false
        }

        onClosed: {
            auraStack.itemAt(auraStack.currentIndex).focus = true
        }

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor

            RowLayout {
                id: tabLblView
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.left: parent.left
                anchors.right: parent.right

                Views.LabelView  {
                    title: "Current Tabs"
                }

                Controls.Label {
                    id: backbtnlabelHeading
                    text: "Press 'esc' or the [←] Back button to close"
                    Layout.alignment: Qt.AlignRight
                }
            }

            Kirigami.Separator {
                id: headrSeptTml
                anchors.top: tabLblView.bottom
                width: parent.width
                height: 1
            }

            Views.TileViewTabs{
                id: tabsListView
                model: tabBarViewModel
                anchors.top: headrSeptTml.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: tabCtrlArea.top
                navigationDown: tabRemoveBtn
                currentIndex: auraStack.currentIndex

                delegate: Delegates.TabDelegate {}

                onCurrentItemChanged: {
                    auraStack.currentIndex = tabsListView.currentIndex
                }
            }

            RowLayout {
                id: tabCtrlArea
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 3

                Controls.Button {
                    id: tabRemoveBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "Remove Tab"
                    KeyNavigation.up: tabsListView

                    background: Rectangle {
                        color: tabRemoveBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 20
                    }

                    onClicked: {
                        if(tabsListView.currentItem.isRemovable){
                            removeTab()
                        } else {
                            console.log("Not Removable Item")
                        }
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log(Aura.GlobalSettings.firstRun);
        console.log(Aura.GlobalSettings.virtualMouseSpeed);
        Cursor.setStep(Aura.GlobalSettings.virtualMouseSpeed);
        if(Aura.GlobalSettings.firstRun){
            RecentStorage.dbInit();
            BookmarkStorage.dbInit();
            BookmarkStorage.prePopulateBookmarks();
            Aura.GlobalSettings.setFirstRun(false);
        }
        prependStartPage();
    }

    Connections {
        target: Aura.GlobalSettings
        onFocusOnVKeyboard: {
           mouseDeActivationRequested();
        }
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: root.height
        width: root.width

        onActiveChanged: {
            if(!active){
                mouseActivationRequested()
                blurFieldRequested();
            }
        }

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: parent.height - inputPanel.height
            }
        }

        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
