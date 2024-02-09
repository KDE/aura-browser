/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtWebEngine 1.7
import QtQuick.Controls 2.12 as Controls
import QtQuick.LocalStorage 2.12
import "views" as Views
import "delegates" as Delegates
import "code/RecentStorage.js" as RecentStorage
import "code/BookmarkStorage.js" as BookmarkStorage
import "code/Utils.js" as Utils
import Aura 1.0 as Aura
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Kirigami.AbstractApplicationWindow {
    id: root
    visible: true
    width:  Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    title: i18n("Aura-Browser")
    property alias showStack: auraStack.currentIndex
    property int virtualMouseMoveSpeed: 10
    signal settingsTabRequested
    signal blurFieldRequested
    signal mouseActivationRequested
    signal mouseDeActivationRequested
    signal ignoreInputRequested
    visibility: "FullScreen"

    onClosing: {
        auraStack.destroy()
    }

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
            text: i18n("Press 'esc' or the [←] Back button to close")
            color: Kirigami.Theme.textColor
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
            KeyNavigation.down: closeMenuButton

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
                    color: Kirigami.Theme.textColor
                    text: "Quit"
                }
            }

            onClicked: (mouse)=> {
                root.close();
            }

            Keys.onReturnPressed: (event)=> {
                root.close();
            }
        }
        Controls.Button {
            id: closeMenuButton
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            KeyNavigation.up: quitButton

            background: Rectangle {
                color: closeMenuButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.disabledTextColor
            }

            contentItem: RowLayout {
                Kirigami.Icon {
                    source: "application-menu"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }

                Controls.Label {
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                    text: i18n("Close Menu")
                }
            }

            onClicked: (mouse)=> {
                gDrawer.close();
            }

            Keys.onReturnPressed: (event)=> {
                gDrawer.close();
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

    Controls.Drawer {
        id: tabBarView
        width: parent.width
        height: parent.height / 3
        edge: Qt.TopEdge
        interactive: true
        dragMargin: 0

        onOpened: {
            tabsListView.forceActiveFocus()
            auraStack.itemAt(auraStack.currentIndex).focus = false
        }

        onClosed: {
            auraStack.itemAt(auraStack.currentIndex).focus = true
        }

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Qt.rgba(0,0,0,0.6)
            } 
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            color: Kirigami.Theme.backgroundColor

            RowLayout {
                id: tabLblView
                anchors.top: parent.top
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.left: parent.left
                anchors.right: parent.right

                Views.LabelView  {
                    title: i18n("Current Tabs")
                }

                Controls.Label {
                    id: backbtnlabelHeading
                    text: i18n("Press 'esc' or the [←] Back button to close")
                    color: Kirigami.Theme.textColor
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
                    text: i18n("Remove Tab")
                    palette.buttonText: Kirigami.Theme.textColor
                    KeyNavigation.up: tabsListView

                    background: Rectangle {
                        color: tabRemoveBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 20
                    }

                    onClicked: (mouse)=> {
                        Aura.NavigationSoundEffects.playClickedSound()
                        if(tabsListView.currentItem.isRemovable){
                            removeTab()
                        } else {
                            console.log("Not Removable Item")
                        }
                    }

                    Keys.onReturnPressed: (event)=> {
                        Aura.NavigationSoundEffects.playClickedSound()
                        if(tabsListView.currentItem.isRemovable){
                            removeTab()
                        } else {
                            console.log("Not Removable Item")
                        }
                    }

                    Keys.onPressed: (event)=> {
                        switch (event.key) {
                            case Qt.Key_Down:
                            case Qt.Key_Right:
                            case Qt.Key_Left:
                            case Qt.Key_Up:
                            case Qt.Key_Tab:
                            case Qt.Key_Backtab:
                                Aura.NavigationSoundEffects.playMovingSound();
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
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
        function onFocusOnVKeyboard() {
           mouseDeActivationRequested();
         }
        function onFocusOffVKeyboard() {
           ignoreInputRequested();
        }
    }

    UrlEntryBox {
        id: urlEntryBox
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: root.height
        width: urlEntryBox.opened ? urlEntryBox.contentItem.width : root.width
        parent: urlEntryBox.opened ? urlEntryBox.contentItem : root.contentItem

        onActiveChanged: {
            if(!active){
                keyFilter.startFilter();
                mouseActivationRequested()
                blurFieldRequested();
            } else {
                keyFilter.stopFilter();
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
