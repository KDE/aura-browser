/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.LocalStorage 2.12
import "views" as Views
import "delegates" as Delegates
import "code/RecentStorage.js" as RecentStorage
import "code/BookmarkStorage.js" as BookmarkStorage
import "code/Utils.js" as Utils
import Aura 1.0 as Aura
import QtWebEngine 1.7
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import org.kde.kirigami as Kirigami

Kirigami.AbstractApplicationWindow {
    id: root
    visible: true
    width:  Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    title: i18n("Aura-Browser")
    property int virtualMouseMoveSpeed: 10
    signal settingsTabRequested
    signal blurFieldRequested
    signal mouseActivationRequested
    signal mouseDeActivationRequested
    signal ignoreInputRequested
    visibility: "FullScreen"

    globalDrawer: Kirigami.GlobalDrawer {
        id: gDrawer
        handleVisible: false

        onOpened: {
            quitButton.forceActiveFocus();
        }

        Controls.Label {
            id: bblabl
            text: i18n("Press 'esc' or the [←] Back button to close")
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
                    text: i18n("Quit")
                }
            }

            onClicked: (mouse)=> {
                root.close();
            }

            Keys.onReturnPressed: (event)=> {
                root.close();
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
        keyFilter.startFilter();
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

    SandboxLoader {
        anchors.fill: parent
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: root.height
        width: root.width

        onActiveChanged: {
            if(!active){
                keyFilter.startFilter();
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
