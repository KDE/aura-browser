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
    width:  Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    title: qsTr("Aura-Browser")
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

    Component.onCompleted: {
        Cursor.setStep(Aura.GlobalSettings.virtualMouseSpeed);
        if(Aura.GlobalSettings.firstRun){
            RecentStorage.dbInit();
            BookmarkStorage.dbInit();
            BookmarkStorage.prePopulateBookmarks();
            Aura.GlobalSettings.setFirstRun(false);
        }
    }

    Connections {
        target: Aura.GlobalSettings
        onFocusOnVKeyboard: {
           mouseDeActivationRequested();
         }
        onFocusOffVKeyboard: {
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
