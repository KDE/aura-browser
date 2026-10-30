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

    title: i18n("Tabs")
    background: BigscreenUI.AmbientBackground {}

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        FocusScope {
            id: buttons

            Layout.fillWidth: true
            Layout.leftMargin: root.contentMargins.left
            Layout.rightMargin: root.contentMargins.right
            Layout.topMargin: Kirigami.Units.gridUnit
            implicitHeight: buttonRow.implicitHeight
            visible: grid.count > 0
            KeyNavigation.down: grid

            RowLayout {
                id: buttonRow

                anchors.fill: parent
                spacing: Kirigami.Units.largeSpacing * 2

                BigscreenUI.KeyNavigationGroup.orientation: Qt.Horizontal

                BigscreenUI.Button {
                    focus: true
                    text: i18n("New tab")
                    icon.name: "tab-new"
                    onClicked: root.window.openAddress("", true)
                }
                BigscreenUI.Button {
                    text: i18n("Close all tabs")
                    icon.name: "tab-close-other"
                    visible: grid.count > 0
                    onClicked: closeAllDialog.open()
                }
                Item { Layout.fillWidth: true }
            }
        }

        BigscreenUI.MediaGrid {
            id: grid

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: count > 0
            focus: count > 0
            model: root.window?.tabs ?? null
            currentIndex: Math.max(0, root.window?.currentTab ?? 0)
            minimumCardWidth: Kirigami.Units.gridUnit * 18
            KeyNavigation.priority: KeyNavigation.AfterItem
            KeyNavigation.up: buttons

            delegate: SiteCard {
                required property int index
                required property var model

                artworkWidth: GridView.view.cardWidth
                artworkHeight: GridView.view.artworkHeight
                url: model.url
                title: model.title
                iconUrl: model.iconUrl
                subtitle: index === root.window?.currentTab ? i18n("Current tab") : host

                onClicked: root.window.selectTab(index)
                onPressAndHold: {
                    closeDialog.index = index;
                    closeDialog.open();
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: grid.count === 0

            BigscreenUI.PlaceholderMessage {
                id: placeholder

                anchors.centerIn: parent
                width: Math.min(parent.width - root.contentMargins.left - root.contentMargins.right, implicitWidth)
                focus: grid.count === 0
                iconName: "tab-new"
                text: i18n("No open tabs")
                helpfulAction: Kirigami.Action {
                    text: i18n("New tab")
                    icon.name: "tab-new"
                    onTriggered: root.window.openAddress("", true)
                }
            }
        }
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
        onClosed: (grid.count > 0 ? grid : placeholder).forceActiveFocus()
    }

    BigscreenUI.Dialog {
        id: closeAllDialog

        title: i18n("Close all tabs?")
        standardButtons: T.Dialog.Cancel | T.Dialog.Ok
        openFocusItem: standardButton(T.Dialog.Cancel)

        contentItem: BigscreenUI.Label {
            text: i18np("1 tab will be closed.", "%1 tabs will be closed.", grid.count)
            wrapMode: Text.Wrap
        }

        Component.onCompleted: standardButton(T.Dialog.Ok).text = i18n("Close All")
        onAccepted: root.window.closeAllTabs()
        onClosed: (grid.count > 0 ? grid : placeholder).forceActiveFocus()
    }
}
