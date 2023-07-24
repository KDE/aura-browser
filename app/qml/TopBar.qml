/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtWebEngine 1.7
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.15
import org.kde.kirigami 2.19 as Kirigami
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils
import Qt5Compat.GraphicalEffects

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
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
                    webView.goBack()
                }
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
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
                    webView.goForward()
                }
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

                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
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
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
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
                    onClicked: (mouse)=> {
                        Aura.NavigationSoundEffects.playClickedSound()
                        webView.reload()
                    }
                }
            }
        }


        Item {
            id: bookmarkButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.right: adblockButtonTopBar.left

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                anchors.centerIn: parent
                source: "bookmark-new"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
                    bookmarkTabManager.bookmarkStack = 1
                    bookmarkTabManager.preBookmarkName = webView.title
                    bookmarkTabManager.preBookmarkUrl = webView.url
                    bookmarkTabManager.open()
                }
            }
        }

        Item {
            id: adblockButtonTopBar
            width: Kirigami.Units.iconSizes.large
            height: Kirigami.Units.iconSizes.large
            anchors.right: tabButtonTopBar.left

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
                    text: i18n("A")
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
                    if(Aura.GlobalSettings.adblockEnabled){
                        Aura.GlobalSettings.setAdblockEnabled(false);
                    } else {
                        Aura.GlobalSettings.setAdblockEnabled(true);
                    }
                }
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
                onClicked: (mouse)=> {
                    Aura.NavigationSoundEffects.playClickedSound()
                    tabBarView.open()
                }
            }
        }
    }
}
