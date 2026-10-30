// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
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

T.Popup {
    id: root

    property alias text: field.text
    property bool inNewTab: false

    signal submitted(string text)
    signal cancelled()

    // TODO: make more suggestions
    readonly property var suggestions: {
        const input = field.text.trim();
        if (input.length === 0) {
            return [];
        }

        const url = Utils.urlFromInput(input, BrowserSettings.searchEngine);
        const isSearch = url.startsWith(BrowserSettings.searchEngine);
        return [{
            text: isSearch ? i18n("Search for \"%1\"", input) : i18n("Go to %1", input),
            description: isSearch ? "" : url,
            icon: isSearch ? "search" : "globe",
            input: input
        }];
    }

    // What was chosen, passed on once the dialog has closed
    property string __input

    function submit(input: string) {
        if (input.trim().length === 0) {
            return;
        }
        __input = input;
        close();
    }

    onClosed: {
        const input = __input;
        __input = "";
        if (input.length > 0) {
            // Submit text once dialog closes
            submitted(input);
        } else {
            cancelled();
        }
    }

    parent: T.Overlay.overlay
    x: 0; y: 0
    width: parent?.width ?? 0
    height: parent?.height ?? 0
    modal: true
    focus: true
    padding: 0

    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false

    BigscreenUI.BackHandler.enabled: visible
    BigscreenUI.BackHandler.onActivated: root.close()

    onOpened: {
        field.forceActiveFocus();
        field.selectAll();
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Kirigami.Units.shortDuration; easing.type: Easing.InCubic }
    }

    T.Overlay.modal: Item {}

    background: BigscreenUI.AmbientBackground {
        intensity: 0.3
    }

    contentItem: FocusScope {
        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Math.max(BigscreenUI.Units.horizontalScreenMarginFor(root.width), (parent.width - Kirigami.Units.gridUnit * 60) / 2)
            anchors.rightMargin: anchors.leftMargin
            anchors.topMargin: BigscreenUI.Units.verticalScreenMarginFor(root.height) + Kirigami.Units.gridUnit * 2
            spacing: Kirigami.Units.gridUnit

            BigscreenUI.Label {
                Layout.fillWidth: true
                text: root.inNewTab ? i18n("New tab") : i18n("Search or enter address")
                type: BigscreenUI.Label.Title
            }

            BigscreenUI.TextField {
                id: field

                Layout.fillWidth: true
                focus: true
                font.pixelSize: BigscreenUI.Units.sectionFontPixelSize
                placeholderText: i18n("Search the web, or type an address")
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhPreferLowercase
                EnterKey.type: Qt.EnterKeyGo
                KeyNavigation.down: suggestionList

                leftPadding: Kirigami.Units.gridUnit * 3

                Kirigami.Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.gridUnit
                    anchors.verticalCenter: parent.verticalCenter
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: "search"
                    color: Kirigami.Theme.disabledTextColor
                }

                onAccepted: root.submit(text)
            }

            ListView {
                id: suggestionList

                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.topMargin: Kirigami.Units.largeSpacing
                interactive: false
                spacing: Kirigami.Units.smallSpacing
                keyNavigationEnabled: true
                model: root.suggestions
                KeyNavigation.up: field

                Keys.onUpPressed: event => {
                    if (currentIndex <= 0) {
                        field.forceActiveFocus();
                    } else {
                        decrementCurrentIndex();
                    }
                }

                delegate: BigscreenUI.ButtonDelegate {
                    id: suggestion

                    required property var modelData

                    width: ListView.view.width
                    text: modelData.text
                    description: modelData.description
                    leading: Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: suggestion.modelData.iconUrl?.toString() || suggestion.modelData.icon || "globe"
                    }
                    onClicked: root.submit(modelData.input)
                }
            }
        }
    }
}
