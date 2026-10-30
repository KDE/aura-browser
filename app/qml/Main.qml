// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Templates as T
import QtWebEngine

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI
import org.kde.aura

import "utils.js" as Utils

BigscreenUI.ApplicationWindow {
    id: root

    width: 1600
    height: 900
    minimumWidth: 500
    minimumHeight: 500
    visibility: Window.Windowed
    title: i18n("Aura Browser")

    component Section: Kirigami.Action {
        required property Item page
    }

    readonly property list<Section> sections: [
        Section {
            text: i18n("Home")
            icon.name: "go-home-symbolic"
            page: HomePage {}
        },
        Section {
            text: i18n("Tabs")
            icon.name: "tab-duplicate-symbolic"
            page: TabsPage {}
        },
        Section {
            text: i18n("Settings")
            icon.name: "configure-symbolic"
            page: SettingsPage {}
        }
    ]

    property int currentSection: 0

    readonly property ListModel tabs: ListModel {}
    property int currentTab: -1

    // Page zoom larger on big screens so text can be read from a distance
    readonly property real zoomFactor: BrowserSettings.zoomFactor > 0
        ? BrowserSettings.zoomFactor
        : Math.max(1, Math.min(2, Math.round(width / 1536 * 4) / 4))

    property bool browsing: false

    readonly property BrowserPage browserPage: browserPageItem

    function showSection(index: int) {
        currentSection = index;
        sidebar.currentIndex = index;
        showPage(sections[index].page);
    }

    function newTab(url: string) {
        tabs.append({ url: url, title: "", iconUrl: "" });
        currentTab = tabs.count - 1;
    }

    function closeTab(index: int) {
        if (index < 0 || index >= tabs.count) {
            return;
        }
        tabs.remove(index);
        if (tabs.count === 0) {
            currentTab = -1;
            if (browsing) {
                showHome();
            }
        } else if (index < currentTab || currentTab >= tabs.count) {
            currentTab = Math.max(0, currentTab - 1);
        }
    }

    function closeAllTabs() {
        currentTab = -1;
        tabs.clear();
        if (browsing) {
            showHome();
        }
    }

    function saveTabs() {
        const urls = [];
        for (let i = 0; i < tabs.count; ++i) {
            const url = tabs.get(i).url;
            if (url.length > 0) {
                urls.push(url);
            }
        }
        BrowserSettings.openTabs = urls;
        BrowserSettings.save();
    }

    function sameUrl(a: string, b: string): bool {
        return a.replace(/\/$/, "") === b.replace(/\/$/, "");
    }

    function selectTab(index: int) {
        currentTab = index;
        showBrowser();
    }

    function load(text: string, inNewTab: bool) {
        const url = Utils.urlFromInput(text, BrowserSettings.searchEngine);
        if (inNewTab || !browserPage.currentView) {
            newTab(url);
        } else {
            browserPage.currentView.url = url;
        }
        showBrowser();
    }

    // Goes to the tab showing the page or opens it in a new one
    function visit(url: string) {
        for (let i = 0; i < tabs.count; ++i) {
            if (sameUrl(tabs.get(i).url, url)) {
                selectTab(i);
                return;
            }
        }
        openUrl(url);
    }

    function openUrl(url: string) {
        newTab(url);
        showBrowser();
    }

    function openAddress(text: string, inNewTab: bool) {
        addressDialog.inNewTab = inNewTab;
        addressDialog.text = text;
        addressDialog.open();
    }

    function showBrowser() {
        if (currentTab < 0) {
            return;
        }
        browsing = true;
        browserPage.forceActiveFocus();
    }

    function showHome() {
        if (browsing) {
            // Nothing keeps playing out of sight
            browserPage.pauseMedia();
            browsing = false;
        }
        showSection(0);
        sections[0].page.forceActiveFocus();
    }

    function showMessage(text: string, iconName: string) {
        toast.show(text, iconName);
    }

    initialPage: sections[0].page

    sidebar: BigscreenUI.Sidebar {
        id: sidebar

        title: i18n("Aura Browser")
        iconName: "org.kde.aura-browser"
        actions: root.sections
        onActivated: index => root.showSection(index)
    }

    Component.onCompleted: {
        if (BrowserSettings.restoreTabs) {
            for (const url of BrowserSettings.openTabs) {
                if (url.length > 0) {
                    tabs.append({ url: url, title: "", iconUrl: "" });
                }
            }
            currentTab = tabs.count - 1;
        }
    }

    onClosing: saveTabs()

    Timer {
        id: saveTabsTimer
        interval: 2000
        onTriggered: root.saveTabs()
    }

    Connections {
        target: root.tabs

        function onCountChanged() {
            saveTabsTimer.restart();
        }

        function onDataChanged() {
            saveTabsTimer.restart();
        }
    }

    AddressDialog {
        id: addressDialog
        onSubmitted: text => root.load(text, inNewTab)
        onCancelled: {
            if (root.browsing) {
                root.browserPage.focusPage();
            }
        }
    }

    BrowserPage {
        id: browserPageItem

        anchors.fill: parent
        active: root.browsing
        opacity: root.browsing ? 1 : 0
        visible: opacity > 0
        enabled: root.browsing

        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.OutCubic } }
    }

    BigscreenUI.Toast {
        id: toast
        z: 1
        timeout: 4000
        anchors.bottomMargin: BigscreenUI.Units.verticalScreenMargin
    }

    Connections {
        target: WebProfile

        function onDownloadRequested(download: WebEngineDownloadRequest): void {
            download.accept();
            root.showMessage(i18n("Downloading %1", download.downloadFileName), "download");
        }

        function onDownloadFinished(download: WebEngineDownloadRequest): void {
            if (download.state === WebEngineDownloadRequest.DownloadCompleted) {
                root.showMessage(i18n("Saved %1 to Downloads", download.downloadFileName), "dialog-ok");
            } else if (download.state === WebEngineDownloadRequest.DownloadInterrupted) {
                root.showMessage(i18n("Could not download %1: %2", download.downloadFileName, download.interruptReasonString), "dialog-warning");
            }
        }
    }
}
