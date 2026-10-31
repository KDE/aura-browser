// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI
import org.kde.aura

BigscreenUI.Page {
    id: root

    readonly property Main window: T.ApplicationWindow.window as Main
    property date now: new Date()

    background: BigscreenUI.AmbientBackground {}

    Timer {
        id: dateTimer
        interval: 30 * 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    BigscreenUI.RailView {
        id: rails

        anchors.fill: parent
        anchors.topMargin: root.contentMargins.top - topMargin
        bottomMargin: root.contentMargins.bottom
        focus: true

        FocusScope {
            implicitHeight: hero.implicitHeight + Kirigami.Units.gridUnit

            ColumnLayout {
                id: hero

                x: root.contentMargins.left
                width: parent.width - x - root.contentMargins.right
                spacing: Kirigami.Units.gridUnit

                BigscreenUI.Label {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(root.now, Qt.locale().timeFormat(Locale.ShortFormat)) + "  ·  " + Qt.formatDate(root.now, "dddd, MMMM d")
                    color: Kirigami.Theme.disabledTextColor
                    type: BigscreenUI.Label.Heading
                }

                BigscreenUI.Label {
                    Layout.fillWidth: true
                    Layout.bottomMargin: Kirigami.Units.gridUnit
                    text: i18n("Browse the web")
                    type: BigscreenUI.Label.Title
                    elide: Text.ElideRight
                }

                BigscreenUI.ButtonDelegate {
                    id: searchButton

                    Layout.preferredWidth: Math.min(hero.width, Kirigami.Units.gridUnit * 45)
                    focus: true
                    icon.name: "search"
                    icon.width: Kirigami.Units.iconSizes.medium
                    icon.height: Kirigami.Units.iconSizes.medium
                    text: i18n("Search or enter address")
                    textFont.pixelSize: BigscreenUI.Units.headingFontPixelSize
                    topPadding: Kirigami.Units.gridUnit * 1.25
                    bottomPadding: Kirigami.Units.gridUnit * 1.25
                    onClicked: root.window.openAddress("", true)
                }
            }
        }

        BigscreenUI.ContentRail {
            id: tabsRail

            title: i18np("1 open tab", "%1 open tabs", count)
            model: root.window?.tabs ?? null
            currentIndex: Math.max(0, root.window?.currentTab ?? 0)

            delegate: SiteCard {
                required property int index
                required property var model

                artworkWidth: Kirigami.Units.gridUnit * 16
                url: model.url
                title: model.title
                iconUrl: model.iconUrl
                current: index === root.window?.currentTab
                onClicked: root.window.selectTab(index)
                onPressAndHold: {
                    closeDialog.index = index;
                    closeDialog.open();
                }
            }
        }
    }

    function restoreFocus(): void {
        (tabsRail.count > 0 ? tabsRail : searchButton).forceActiveFocus();
    }

    BigscreenUI.Dialog {
        id: closeDialog

        property int index: -1

        title: i18n("Close this tab?")
        standardButtons: T.Dialog.Cancel | T.Dialog.Ok
        openFocusItem: standardButton(T.Dialog.Ok)

        contentItem: BigscreenUI.Label {
            text: {
                const tab = root.window?.tabs.get(closeDialog.index);
                return tab ? (tab.title || tab.url) : "";
            }
            wrapMode: Text.Wrap
            color: Kirigami.Theme.disabledTextColor
        }

        Component.onCompleted: standardButton(T.Dialog.Ok).text = i18n("Close Tab")
        onAccepted: root.window.closeTab(index)
        onClosed: root.restoreFocus()
    }
}
