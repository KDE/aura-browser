// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI
import org.kde.aura

import "utils.js" as Utils

// The browser's controls and tabs, rising over the bottom of the page
FocusScope {
    id: root

    property WebView view
    property bool opened: false

    readonly property Main window: T.ApplicationWindow.window as Main

    signal closed()
    signal pointerNavigationToggled()

    function open() {
        opened = true;

        if (backButton.enabled) {
            backButton.forceActiveFocus();
        } else {
            addressButton.forceActiveFocus();
        }
    }

    function close() {
        if (!opened) {
            return;
        }
        opened = false;
        closed();
    }

    function run(action: var) {
        close();
        action();
    }

    enabled: opened
    visible: opacity > 0
    opacity: opened ? 1 : 0

    Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }

    BigscreenUI.BackHandler.enabled: opened
    BigscreenUI.BackHandler.onActivated: close()

    Rectangle {
        id: bottomScrim
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.5) }
            GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.94) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.98) }
        }
    }

    MouseArea {
        id: closeClickArea
        anchors.fill: parent
        onClicked: root.close()
    }

    component ControlButton: BigscreenUI.RoundButton {
        Layout.alignment: Qt.AlignVCenter
        Accessible.name: text
    }

    ColumnLayout {
        id: panel

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: BigscreenUI.Units.horizontalScreenMarginFor(root.width)
        anchors.rightMargin: BigscreenUI.Units.horizontalScreenMarginFor(root.width)
        anchors.bottomMargin: BigscreenUI.Units.verticalScreenMarginFor(root.height) + (root.opened ? 0 : Kirigami.Units.gridUnit * 3)
        spacing: 0

        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        Behavior on anchors.bottomMargin { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }

        RowLayout {
            id: pageInfoRow
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit * 1.5
            spacing: Kirigami.Units.gridUnit

            SiteTile {
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                iconUrl: root.view?.iconSource ?? ""
                host: addressButton.host
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                BigscreenUI.Label {
                    Layout.fillWidth: true
                    text: root.view?.title || addressButton.host
                    type: BigscreenUI.Label.Section
                    elide: Text.ElideRight
                }
                BigscreenUI.Label {
                    Layout.fillWidth: true
                    text: {
                        const parts = [addressButton.host];
                        if (root.view?.loading) {
                            parts.push(i18n("Loading… %1%", root.view.loadProgress));
                        }
                        if (root.view && Math.abs(root.view.zoomFactor - (root.window?.zoomFactor ?? 1)) > 0.01) {
                            parts.push(i18n("Zoom %1%", Math.round(root.view.zoomFactor * 100)));
                        }
                        return parts.join("  ·  ");
                    }
                    color: Kirigami.Theme.disabledTextColor
                    elide: Text.ElideRight
                }
            }
        }

        FocusScope {
            id: actions

            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit * 0.5
            implicitHeight: actionRow.implicitHeight
            KeyNavigation.down: tabRail.count > 0 ? tabRail : null

            RowLayout {
                id: actionRow

                anchors.fill: parent
                spacing: Kirigami.Units.largeSpacing * 2

                BigscreenUI.KeyNavigationGroup.orientation: Qt.Horizontal

                ControlButton {
                    id: backButton
                    text: i18n("Back")
                    icon.name: "go-previous"
                    enabled: root.view?.canGoBack ?? false
                    onClicked: root.view.goBack()

                    // The history runs out once the page has gone back and a disabled button drops focus
                    onActiveFocusChanged: {
                        if (!activeFocus && !enabled) {
                            homeButton.forceActiveFocus();
                        }
                    }
                }
                ControlButton {
                    id: forwardButton
                    text: i18n("Forward")
                    icon.name: "go-next"
                    enabled: root.view?.canGoForward ?? false
                    onClicked: root.view.goForward()
                    onActiveFocusChanged: {
                        if (!activeFocus && !enabled) {
                            homeButton.forceActiveFocus();
                        }
                    }
                }
                ControlButton {
                    id: homeButton
                    text: i18n("Home")
                    icon.name: "go-home-symbolic"
                    onClicked: {
                        root.close();
                        root.window.showHome();
                    }
                }

                BigscreenUI.Button {
                    id: addressButton

                    readonly property string host: Utils.siteHost(root.view?.url)

                    Layout.fillWidth: true
                    icon.name: root.view?.url.toString().startsWith("https:") ? "lock" : "globe"
                    text: root.view?.url.toString() ?? ""
                    Accessible.name: i18n("Address: %1", text)
                    onClicked: {
                        const url = root.view?.url.toString() ?? "";
                        root.run(() => root.window.openAddress(url, false));
                    }
                }

                ControlButton {
                    text: root.view?.loading ? i18n("Stop") : i18n("Reload")
                    icon.name: root.view?.loading ? "process-stop" : "view-refresh"
                    onClicked: root.view.loading ? root.view.stop() : root.view.reload()
                }

                ControlButton {
                    text: i18n("Zoom out")
                    icon.name: "zoom-out"
                    onClicked: root.view.zoomFactor = Math.max(0.5, root.view.zoomFactor - 0.1)
                }
                ControlButton {
                    text: i18n("Zoom in")
                    icon.name: "zoom-in"
                    onClicked: root.view.zoomFactor = Math.min(3, root.view.zoomFactor + 0.1)
                }
                ControlButton {
                    text: i18n("New tab")
                    icon.name: "tab-new"
                    onClicked: root.run(() => root.window.openAddress("", true))
                }
                ControlButton {
                    text: i18n("Close tab")
                    icon.name: "tab-close"
                    onClicked: root.run(() => root.window.closeTab(root.window.currentTab))
                }
            }
        }

        BigscreenUI.Label {
            id: focusedButtonLabel
            Layout.fillWidth: true
            Layout.bottomMargin: Kirigami.Units.gridUnit * 1.5
            horizontalAlignment: Text.AlignHCenter
            text: {
                const item = root.Window.activeFocusItem;
                return item instanceof BigscreenUI.RoundButton && item.parent === actionRow ? item.text : "";
            }
            opacity: text.length > 0 ? 1 : 0
            color: Kirigami.Theme.disabledTextColor
        }

        BigscreenUI.ContentRail {
            id: tabRail

            Layout.fillWidth: true
            Layout.leftMargin: -panel.anchors.leftMargin
            Layout.rightMargin: -panel.anchors.rightMargin
            leftPadding: panel.anchors.leftMargin
            rightPadding: panel.anchors.rightMargin

            title: i18np("1 tab", "%1 tabs", count)
            model: root.window?.tabs ?? null
            currentIndex: root.window?.currentTab ?? 0
            KeyNavigation.up: actions

            delegate: SiteCard {
                required property int index
                required property var model

                artworkWidth: Kirigami.Units.gridUnit * 11
                url: model.url
                title: model.title
                iconUrl: model.iconUrl
                current: index === root.window?.currentTab

                onClicked: {
                    root.close();
                    root.window.selectTab(index);
                }
            }
        }
    }
}
