/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtWebEngine 1.7
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import QtQuick.Controls 2.15 as Controls
import QtQml.Models 2.15
import QtQuick.LocalStorage 2.15
import QtQuick.VirtualKeyboard 2.15
import "code/BookmarkStorage.js" as BookmarkStorage
import Qt5Compat.GraphicalEffects

Controls.Popup {
    id: helpPopupArea
    width: Math.max((parent.width / 2), (remotenavheading.contentWidth + Kirigami.Units.largeSpacing))
    height: headerAreaHelpPage.implicitHeight + helperContent.implicitHeight + Kirigami.Units.largeSpacing
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

    Item {
        anchors.fill: parent

        RowLayout {
            id: headerAreaHelpPage
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Kirigami.Heading {
                id: helpTabHeading
                level: 1
                text: i18n("Help")
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
                color: Kirigami.Theme.textColor
            }

            Controls.Label {
                id: backbtnlabelHeading
                text: i18n("Press 'esc' or the [←] Back button to close")
                Layout.alignment: Qt.AlignRight
                color: Kirigami.Theme.textColor
            }
        }

        Kirigami.Separator {
            id: headerSeparator
            anchors.top: headerAreaHelpPage.bottom
            width: parent.width
            height: 1
        }

        ColumnLayout {
            id: helperContent
            anchors.top: headerSeparator.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 0

            Controls.Label {
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Kirigami.Theme.textColor
                text: i18n("Aura Browser adapts the traditional web browser UI for a fully immersed Bigscreen experience. Aura Browser UI is kept as subtle and intuitive as possible for navigating the world wide web using just your remote control.")
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: Kirigami.Units.smallSpacing
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 18
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Kirigami.Heading {
                    id: remotenavheading
                    level: 3
                    anchors.bottom: remoteImage.top
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.SmallCaps
                    color: Kirigami.Theme.textColor
                    text: i18n("Here are all the buttons required to help you get started with using aura browser")
                }

                Image {
                    id: remoteImage
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    width: Kirigami.Units.gridUnit * 15
                    height: Kirigami.Units.gridUnit * 15
                    source: Qt.resolvedUrl("./images/remote.png")
                }

                ColorOverlay {
                    anchors.fill: remoteImage
                    source: remoteImage
                    color: Kirigami.Theme.textColor
                }
            }
        }
    }
}
