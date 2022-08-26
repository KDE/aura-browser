/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12 as Controls
import QtGraphicalEffects 1.0
import QtQml.Models 2.12
import QtQuick.LocalStorage 2.12
import QtQuick.VirtualKeyboard 2.4
import Aura 1.0 as Aura

Controls.Popup {
    id: settingsPopupArea
    width: parent.width / 2
    height: settingContents.implicitHeight + headerAreaSettingsPage.implicitHeight + Kirigami.Units.gridUnit * 5 //parent.height / 2
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    padding: Kirigami.Units.largeSpacing
    dim: true

    Controls.Overlay.modeless: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.77)
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        border.color: "black"
    }

    onOpened: {
        virtualMouseMoveSpeedSlider.forceActiveFocus()
    }

    function playKeySounds(event){
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

    Connections {
        target: Aura.GlobalSettings
        onVirtualMouseSpeedChanged: {
            console.log("Mouse Speed: " + virtualMouseSpeed);
            Cursor.setStep(virtualMouseSpeed);
        }
    }

    Item {
        anchors.fill: parent

        RowLayout {
            id: headerAreaSettingsPage
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Kirigami.Heading {
                id: settingsTabHeading
                level: 1
                text: "Settings"
                color: Kirigami.Theme.textColor
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Controls.Label {
                id: backbtnlabelHeading
                text: "Press 'esc' or the [←] Back button to close"
                color: Kirigami.Theme.textColor
                Layout.alignment: Qt.AlignRight
            }
        }

        Kirigami.Separator {
            id: headerSeparator
            anchors.top: headerAreaSettingsPage.bottom
            width: parent.width
            height: 1
        }

        ColumnLayout {
            id: settingContents
            anchors.centerIn: parent

            Kirigami.Heading {
                id: virtualMouseSpeedSettingLabel
                level: 2
                text: "Virtual Cursor Speed Control"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: virtualMouseMoveSpeedSlider.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Controls.Slider {
                id: virtualMouseMoveSpeedSlider
                Layout.fillWidth:  true
                snapMode: Controls.Slider.SnapAlways
                stepSize: 5
                from: 5
                to: 100
                value: Aura.GlobalSettings.virtualMouseSpeed
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Layout.alignment: Qt.AlignTop
                KeyNavigation.down: virtualScrollMoveSpeedSlider

                background: Rectangle {
                    x: virtualMouseMoveSpeedSlider.leftPadding
                    y: virtualMouseMoveSpeedSlider.topPadding + virtualMouseMoveSpeedSlider.availableHeight / 2 - height / 2
                    implicitWidth: width
                    width: virtualMouseMoveSpeedSlider.availableWidth
                    height: Kirigami.Units.smallSpacing
                    radius: 2
                    color: virtualMouseMoveSpeedSlider.activeFocus ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor

                    Rectangle {
                        width: virtualMouseMoveSpeedSlider.visualPosition * parent.width
                        height: parent.height
                        color: Kirigami.Theme.linkColor
                        radius: 2
                    }
                }

                onValueChanged: {
                    console.log(virtualMouseMoveSpeedSlider.value)
                    Aura.GlobalSettings.setVirtualMouseSpeed(value);
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Kirigami.Heading {
                id: currentVirtualMouseSpeedLabel
                level: 3
                text: "Current Speed: " + virtualMouseMoveSpeedSlider.value
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.gridUnit
                Layout.fillWidth: true
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Kirigami.Heading {
                id: virtualScrollSpeedSettingLabel
                level: 2
                text: "Virtual Scroll Speed Control"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: virtualScrollMoveSpeedSlider.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Controls.Slider {
                id: virtualScrollMoveSpeedSlider
                Layout.fillWidth:  true
                snapMode: Controls.Slider.SnapAlways
                stepSize: 5
                from: 5
                to: 100
                value: Aura.GlobalSettings.virtualScrollSpeed
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Layout.alignment: Qt.AlignTop
                KeyNavigation.up: virtualMouseMoveSpeedSlider
                KeyNavigation.down: virtualCursorSizeSlider

                background: Rectangle {
                    x: virtualScrollMoveSpeedSlider.leftPadding
                    y: virtualScrollMoveSpeedSlider.topPadding + virtualScrollMoveSpeedSlider.availableHeight / 2 - height / 2
                    implicitWidth: width
                    width: virtualScrollMoveSpeedSlider.availableWidth
                    height: Kirigami.Units.smallSpacing
                    radius: 2
                    color: virtualScrollMoveSpeedSlider.activeFocus ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor

                    Rectangle {
                        width: virtualScrollMoveSpeedSlider.visualPosition * parent.width
                        height: parent.height
                        color: Kirigami.Theme.linkColor
                        radius: 2
                    }
                }

                onValueChanged: {
                    console.log(virtualScrollMoveSpeedSlider.value)
                    Aura.GlobalSettings.setVirtualScrollSpeed(value);
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Kirigami.Heading {
                id: currentVirtualScrollSpeedLabel
                level: 3
                text: "Current Speed: " + virtualScrollMoveSpeedSlider.value
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.gridUnit
                Layout.fillWidth: true
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Kirigami.Heading {
                id: virtualCursorSizeSettingLabel
                level: 2
                text: "Virtual Cursor Size Control"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: virtualCursorSizeSlider.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Controls.Slider {
                id: virtualCursorSizeSlider
                Layout.fillWidth:  true
                snapMode: Controls.Slider.SnapAlways
                stepSize: 0.1
                from: 0.8
                to: 1
                value: Aura.GlobalSettings.virtualMouseSize
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Layout.alignment: Qt.AlignTop
                KeyNavigation.up: virtualScrollMoveSpeedSlider
                KeyNavigation.down: defSearchBtn1

                background: Rectangle {
                    x: virtualCursorSizeSlider.leftPadding
                    y: virtualCursorSizeSlider.topPadding + virtualCursorSizeSlider.availableHeight / 2 - height / 2
                    implicitWidth: width
                    width: virtualCursorSizeSlider.availableWidth
                    height: Kirigami.Units.smallSpacing
                    radius: 2
                    color: virtualCursorSizeSlider.activeFocus ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor

                    Rectangle {
                        width: virtualCursorSizeSlider.visualPosition * parent.width
                        height: parent.height
                        color: Kirigami.Theme.linkColor
                        radius: 2
                    }
                }

                onValueChanged: {
                    console.log(virtualCursorSizeSlider.value)
                    Aura.GlobalSettings.setVirtualMouseSize(value);
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Kirigami.Heading {
                id: currentVirtualCursorSizeLabel
                level: 3
                text: "Current Size: " + Aura.GlobalSettings.virtualMouseSize == 1 ? "Large" : (Aura.GlobalSettings.virtualMouseSize == 0.9 ? "Medium" : (Aura.GlobalSettings.virtualMouseSize == 0.8 ? "Small": "Large")) 
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.preferredHeight: Kirigami.Units.gridUnit
                Layout.fillWidth: true
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Kirigami.Heading {
                id: defSearchSettingLabel
                level: 2
                text: "Search Engine"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: defSearchBtn1.activeFocus || defSearchBtn2.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2

                Controls.Button {
                    id: defSearchBtn1
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    Layout.alignment: Qt.AlignLeft
                    text: "Google"
                    KeyNavigation.up: virtualCursorSizeSlider
                    KeyNavigation.down: soundEffectsButton
                    KeyNavigation.right: defSearchBtn2
                    palette.buttonText: Kirigami.Theme.textColor

                    background: Rectangle {
                        color: defSearchBtn1.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                        border.color: Aura.GlobalSettings.defaultSearchEngine == "Google" ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                        border.width: Aura.GlobalSettings.defaultSearchEngine == "Google" ? 4 : 1
                        radius: 2
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }

                    onClicked: {
                        Aura.GlobalSettings.setDefaultSearchEngine("Google")
                    }
                }

                Controls.Button {
                    id: defSearchBtn2
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    Layout.alignment: Qt.AlignLeft
                    text: "Duck Duck Go"
                    KeyNavigation.up: virtualCursorSizeSlider
                    KeyNavigation.down: soundEffectsButton
                    KeyNavigation.left: defSearchBtn1
                    palette.buttonText: Kirigami.Theme.textColor

                    background: Rectangle {
                        color: defSearchBtn2.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                        border.color: Aura.GlobalSettings.defaultSearchEngine == "DDG" ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                        border.width: Aura.GlobalSettings.defaultSearchEngine == "DDG" ? 4 : 1
                        radius: 2
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }

                    onClicked: {
                        Aura.GlobalSettings.setDefaultSearchEngine("DDG")
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Kirigami.Heading {
                id: miscSettingLabel
                level: 2
                text: "General"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                color: soundEffectsButton.activeFocus || clearCacheButton.activeFocus ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Controls.Button {
                id: soundEffectsButton
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                Layout.alignment: Qt.AlignLeft
                text: "Disable Button Sounds"
                KeyNavigation.up: defSearchBtn1
                KeyNavigation.down: clearCacheButton
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: soundEffectsButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 2
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    if(Aura.GlobalSettings.soundEffects){
                        Aura.GlobalSettings.setSoundEffects(false);
                        text = "Enable Button Sounds"
                    } else {
                        Aura.GlobalSettings.setSoundEffects(true);
                        text = "Disable Button Sounds"
                    }
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: clearCacheButton
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                Layout.alignment: Qt.AlignLeft
                text: "Clear Cache"
                KeyNavigation.up: soundEffectsButton
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: clearCacheButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 2
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    Aura.GlobalSettings.clearDefaultProfileCache();
                }

                Keys.onReturnPressed: {
                    clicked()
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }
        }
    }
}
