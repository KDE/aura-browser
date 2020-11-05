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
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Controls.Label {
                id: backbtnlabelHeading
                text: "Press 'esc' or the [←] Back button to close"
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
            }

            Kirigami.Heading {
                id: currentVirtualMouseSpeedLabel
                level: 3
                text: "Current Speed: " + virtualMouseMoveSpeedSlider.value
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
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
                KeyNavigation.down: clearCacheButton

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
            }

            Kirigami.Heading {
                id: currentVirtualScrollSpeedLabel
                level: 3
                text: "Current Speed: " + virtualScrollMoveSpeedSlider.value
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
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
                id: miscSettingLabel
                level: 2
                text: "General"
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Controls.Button {
                id: clearCacheButton
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                Layout.alignment: Qt.AlignLeft
                text: "Clear Cache"
                KeyNavigation.up: virtualScrollMoveSpeedSlider

                background: Rectangle {
                    color: clearCacheButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 2
                }

                onClicked: {
                    Aura.GlobalSettings.clearDefaultProfileCache();
                }

                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
    }
}
