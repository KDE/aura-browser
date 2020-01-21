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

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Window 2.10
import QtWebEngine 1.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.0
import org.kde.kirigami 2.11 as Kirigami
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils

Rectangle {
    width: parent.width
    height: Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing
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
        height: Kirigami.Units.iconSizes.large
        anchors.centerIn: parent

        Item {
            id: backButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.left: parent.left

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "arrow-left"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {webView.goBack()}
            }
        }

        Item {
            id: forwardButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.left: backButtonTopBar.right

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "arrow-right"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {webView.goForward()}
            }
        }

        Rectangle {
            id: homeButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.left: forwardButtonTopBar.right
            color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "go-home"
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    auraStack.currentIndex = 0
                    auraStack.itemAt(0).focus = true
                    auraStack.itemAt(0).forceActiveFocus();
                }
            }
        }

        Rectangle {
            id: urlBox
            anchors.left: homeButtonTopBar.right
            anchors.right: bookmarkButtonTopBar.left
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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    localUrlEntryDrawer.open()
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
                    onClicked: {webView.reload()}
                }
            }
        }


        Item {
            id: bookmarkButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.right: tabButtonTopBar.left

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "bookmark-new"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }

        Item {
            id: tabButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.right: parent.right

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "layer-duplicate"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {tabBarView.open()}
            }
        }
    }
}
