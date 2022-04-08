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
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.12
import org.kde.kirigami 2.11 as Kirigami
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils

Rectangle {
    property bool viewFullscreenMode: false
    width: parent.width
    height: viewFullscreenMode ? 0 : Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing
    color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
    layer.enabled: true
    z: 1000
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 1
        radius: 8.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
    }

    Item {
        id: tbarLayout
        width: parent.width
        visible: viewFullscreenMode ? 0 : 1
        enabled: viewFullscreenMode ? 0 : 1
        height: Kirigami.Units.iconSizes.large
        anchors.centerIn: parent

        Item {
            id: menuButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.left: parent.left

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "application-menu"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound()
                    gDrawer.open()
                }
            }
        }

        Rectangle {
            id: urlBox
            anchors.left: menuButtonTopBar.right
            anchors.right: adblockButtonTopBar.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.rightMargin: Kirigami.Units.largeSpacing
            anchors.verticalCenter: parent.verticalCenter
            height: Kirigami.Units.iconSizes.medium
            radius: 20
            color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 0.5

            Image {
                id: websiteImgIcon
                width: Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Kirigami.Units.largeSpacing
                source: webView.icon
            }

            Kirigami.Separator {
                id: urlboxsept
                width: 1
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: websiteImgIcon.right
                anchors.margins: Kirigami.Units.smallSpacing
            }

            Item {
                anchors.left: urlboxsept.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                height: parent.height
                width: urlBox.width - (websiteImgIcon.width + refreshbtn.width + Kirigami.Units.largeSpacing * 4)

                RowLayout {
                    anchors.fill: parent
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        maximumLineCount: 1
                        Layout.maximumWidth: parent.width
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        wrapMode: Text.WrapAnywhere
                        color: Kirigami.Theme.textColor
                        text: webView.url
                    }
                }
            }

            Item {
                id: refreshbtn
                anchors.right: parent.right
                width: Kirigami.Units.iconSizes.medium
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Kirigami.Icon {
                    source: "refactor"
                    width: Kirigami.Units.iconSizes.small
                    height: Kirigami.Units.iconSizes.small
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Aura.NavigationSoundEffects.playClickedSound()
                        webView.reload()
                    }
                }
            }
        }

        Item {
            id: adblockButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.right: parent.right

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "draw-polygon"
                color: Aura.GlobalSettings.adblockEnabled ? "green" : "red"

                Label {
                    color: Kirigami.Theme.textColor
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 2
                    font.bold: true
                    font.pixelSize: parent.height * 0.5
                    font.strikeout: !Aura.GlobalSettings.adblockEnabled
                    text: "A"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound()
                    if(Aura.GlobalSettings.adblockEnabled){
                        Aura.GlobalSettings.setAdblockEnabled(false);
                    } else {
                        Aura.GlobalSettings.setAdblockEnabled(true);
                    }
                }
            }
        }
    }
}
