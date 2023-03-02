/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.19 as Kirigami
import QtQuick.Layouts 1.15
import Aura 1.0 as Aura
import Qt5Compat.GraphicalEffects

Popup {
    id: audioRecorderBox
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    onOpenedChanged: {
        if(opened) {
            audBoxCloseBtn.forceActiveFocus()
        }
    }

    onClosed: {
        Aura.AudioRecorder.stop()
        parent.forceActiveFocus()
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
        radius: Kirigami.Units.smallSpacing * 0.25
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.disabledTextColor.r, Kirigami.Theme.disabledTextColor.g, Kirigami.Theme.disabledTextColor.b, 0.7)
    }

    ColumnLayout {
        id: closebar
        anchors.fill: parent
        spacing: 0

        Kirigami.Heading {
            id: lbl1
            text: i18n("Listening")
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            level: 2
            font.bold: true
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.Theme.disabledTextColor
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: animatedCircle
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                radius: 1000
                color: Qt.rgba(Kirigami.Theme.linkColor.r, Kirigami.Theme.linkColor.g, Kirigami.Theme.linkColor.b, 0.7)

                Image {
                    source: "images/microphone.svg"
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                }
            }
        }

        Kirigami.Heading {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            Layout.preferredHeight: paintedHeight
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            level: 3
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Performing Search With Mycroft")
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.smallSpacing * 0.15

            ProgressBar {
                id: bar
                to: 100
                from: 0
                anchors.fill: parent

                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    color: Kirigami.Theme.disabledTextColor
                }

                contentItem: Item {
                    implicitWidth: parent.width
                    implicitHeight: parent.height

                    Rectangle {
                        width: bar.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Kirigami.Theme.linkColor }
                            GradientStop { position: 1.0; color: Kirigami.Theme.linkColor }
                        }
                    }
                }

                NumberAnimation {
                    id: numAnim
                    target: bar
                    property: "value"
                    from: 0
                    to: 100
                    duration: 10000
                }
            }
        }

        Rectangle {
            id: audBoxCloseBtn
            color: activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5

            Kirigami.Heading {
                level: 2
                text: i18n("Close")
                anchors.centerIn: parent
                anchors.margins: Kirigami.Units.largeSpacing
            }

            Keys.onReturnPressed: (event)=> {
                audioRecorderBox.close()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse)=> {
                    audioRecorderBox.close()
                }
            }
        }
    }
}
