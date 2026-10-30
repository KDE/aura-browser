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

BigscreenUI.ScrollablePage {
    id: root

    readonly property Main window: T.ApplicationWindow.window as Main

    readonly property var searchEngines: [
        { text: "DuckDuckGo", value: "https://duckduckgo.com/?q=" },
        { text: "Google", value: "https://www.google.com/search?q=" },
        { text: "Bing", value: "https://www.bing.com/search?q=" },
        { text: "Brave Search", value: "https://search.brave.com/search?q=" },
        { text: "Ecosia", value: "https://www.ecosia.org/search?q=" },
        { text: "Startpage", value: "https://www.startpage.com/do/search?query=" },
        { text: "Qwant", value: "https://www.qwant.com/?q=" }
    ]

    readonly property var zoomLevels: [
        { text: i18n("Automatic (%1%)", Math.round((window?.zoomFactor ?? 1) * 100)), value: 0 },
        { text: i18n("100%"), value: 1 },
        { text: i18n("125%"), value: 1.25 },
        { text: i18n("150%"), value: 1.5 },
        { text: i18n("175%"), value: 1.75 },
        { text: i18n("200%"), value: 2 }
    ]

    readonly property var pointerSpeeds: [
        { text: i18n("Slow"), value: 2 },
        { text: i18n("Normal"), value: 5 },
        { text: i18n("Fast"), value: 8 },
        { text: i18n("Fastest"), value: 10 }
    ]

    function indexOf(options: var, value: var): int {
        return Math.max(0, options.findIndex(option => option.value === value));
    }

    component SectionHeading: BigscreenUI.Label {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.gridUnit * 2
        Layout.bottomMargin: Kirigami.Units.largeSpacing
        type: BigscreenUI.Label.Heading
        color: Kirigami.Theme.disabledTextColor
    }

    title: i18n("Settings")
    background: BigscreenUI.AmbientBackground {}

    ColumnLayout {
        width: root.availableWidth
        spacing: Kirigami.Units.smallSpacing

        BigscreenUI.KeyNavigationGroup.orientation: Qt.Vertical

        SectionHeading {
            Layout.topMargin: 0
            text: i18n("Browsing")
        }

        BigscreenUI.ComboBoxDelegate {
            Layout.fillWidth: true
            focus: true
            text: i18n("Search engine")
            icon.name: "search"
            model: root.searchEngines
            textRole: "text"
            valueRole: "value"
            currentIndex: {
                const index = root.searchEngines.findIndex(engine => engine.value === BrowserSettings.searchEngine);
                return index >= 0 ? index : 0;
            }
            onActivated: index => {
                BrowserSettings.searchEngine = root.searchEngines[index].value;
                BrowserSettings.save();
            }
        }

        BigscreenUI.SwitchDelegate {
            Layout.fillWidth: true
            text: i18n("Block ads")
            description: i18n("Hides ads and trackers on most sites")
            icon.name: "security-high"
            checked: BrowserSettings.adblockEnabled
            onToggled: {
                BrowserSettings.adblockEnabled = checked;
                BrowserSettings.save();
            }
        }

        BigscreenUI.SwitchDelegate {
            Layout.fillWidth: true
            text: i18n("Dark pages")
            description: i18n("Shows light pages in dark colors")
            icon.name: "lighttable"
            checked: BrowserSettings.forceDarkMode
            onToggled: {
                BrowserSettings.forceDarkMode = checked;
                BrowserSettings.save();
            }
        }

        BigscreenUI.ComboBoxDelegate {
            Layout.fillWidth: true
            text: i18n("Page zoom")
            icon.name: "zoom"
            model: root.zoomLevels
            textRole: "text"
            valueRole: "value"
            currentIndex: root.indexOf(root.zoomLevels, BrowserSettings.zoomFactor)
            onActivated: index => {
                BrowserSettings.zoomFactor = root.zoomLevels[index].value;
                BrowserSettings.save();
            }
        }

        BigscreenUI.SwitchDelegate {
            Layout.fillWidth: true
            text: i18n("Reopen tabs")
            description: i18n("Brings back the tabs that were open when the browser last closed")
            icon.name: "tab-duplicate"
            checked: BrowserSettings.restoreTabs
            onToggled: {
                BrowserSettings.restoreTabs = checked;
                BrowserSettings.save();
            }
        }

        SectionHeading {
            text: i18n("Remote control")
        }

        BigscreenUI.ComboBoxDelegate {
            Layout.fillWidth: true
            text: i18n("Arrow keys on pages")
            icon.name: "input-gamepad"
            model: [i18n("Move between links"), i18n("Move a pointer")]
            currentIndex: BrowserSettings.pointerNavigation ? 1 : 0
            onActivated: index => {
                BrowserSettings.pointerNavigation = index === 1;
                BrowserSettings.save();
            }
        }

        BigscreenUI.ComboBoxDelegate {
            Layout.fillWidth: true
            text: i18n("Pointer speed")
            icon.name: "input-mouse"
            model: root.pointerSpeeds
            textRole: "text"
            valueRole: "value"
            currentIndex: root.indexOf(root.pointerSpeeds, BrowserSettings.pointerSpeed)
            onActivated: index => {
                BrowserSettings.pointerSpeed = root.pointerSpeeds[index].value;
                BrowserSettings.save();
            }
        }

        SectionHeading {
            text: i18n("Privacy")
        }

        BigscreenUI.ButtonDelegate {
            id: clearDataButton

            Layout.fillWidth: true
            text: i18n("Clear site data…")
            description: i18n("Signs you out of sites, and forgets cached pages and permissions")
            icon.name: "edit-clear"
            onClicked: clearDataDialog.open()
        }

        SectionHeading {
            text: i18n("About")
        }

        BigscreenUI.AboutDelegate {
            Layout.fillWidth: true
            icon.name: "org.kde.aura-browser"
        }
    }

    BigscreenUI.Dialog {
        id: clearDataDialog

        title: i18n("Clear site data?")
        standardButtons: T.Dialog.Cancel | T.Dialog.Ok
        openFocusItem: standardButton(T.Dialog.Cancel)

        contentItem: BigscreenUI.Label {
            text: i18n("You will be signed out of sites.")
            wrapMode: Text.Wrap
        }

        Component.onCompleted: standardButton(T.Dialog.Ok).text = i18n("Clear")
        onAccepted: {
            WebProfile.clearSiteData();
            root.window.showMessage(i18n("Site data cleared"), "edit-clear");
        }
        onClosed: clearDataButton.forceActiveFocus()
    }
}
