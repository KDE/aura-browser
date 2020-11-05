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
import "code/BookmarkStorage.js" as BookmarkStorage

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
                text: "Help"
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
                text: "Aura Browser adapts the traditional web browser UI for a fully immersed Bigscreen experience. Aura Browser UI is kept as subtle and intuitive as possible for navigating the world wide web using just your remote control."
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
                    text: "Here are all the buttons required to help you get started with using aura browser"
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
