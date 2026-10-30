// SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Templates as T
import QtWebChannel
import QtWebEngine

import org.kde.kirigami as Kirigami
import org.kde.aura

WebEngineView {
    id: root

    required property int index

    // Whether this is the current tab
    property bool current: false

    property bool pointerNavigation: BrowserSettings.pointerNavigation

    // Whether a text field in the page has focus
    readonly property alias editing: bridge.editing

    readonly property Main window: T.ApplicationWindow.window as Main
    readonly property ListModel tabs: window?.tabs ?? null

    readonly property url iconSource: icon.toString().replace(/^image:\/\/favicon\//, "")

    function blurField(): void {
        runJavaScript("document.activeElement && document.activeElement.blur()", WebEngineScript.ApplicationWorld);
    }

    function pauseMedia(): void {
        runJavaScript(`document.querySelectorAll("video, audio").forEach(media => media.pause())`, WebEngineScript.ApplicationWorld);
    }

    // Plays or pauses the video or audio playing in the page
    function togglePlayback(): void {
        runJavaScript(`(function () {
            const media = Array.from(document.querySelectorAll("video, audio"));
            const playing = media.find(element => !element.paused);
            if (playing) {
                playing.pause();
            } else if (media.length > 0) {
                media[0].play();
            }
        })()`, WebEngineScript.ApplicationWorld);
    }

    function updateTab(role: string, value: var): void {
        if (tabs && index >= 0 && index < tabs.count) {
            tabs.setProperty(index, role, value);
        }
    }

    readonly property url tabUrl: url.toString().length > 0 ? root.url : root.initialUrl
    property url initialUrl

    profile: WebProfile
    zoomFactor: window?.zoomFactor ?? 1
    backgroundColor: BrowserSettings.forceDarkMode ? Kirigami.Theme.backgroundColor : "white"
    webChannel: channel
    webChannelWorld: WebEngineScript.ApplicationWorld

    // Freeze background tabs
    lifecycleState: current ? WebEngineView.LifecycleState.Active : recommendedState

    settings.spatialNavigationEnabled: !pointerNavigation
    settings.forceDarkMode: BrowserSettings.forceDarkMode
    settings.showScrollBars: false
    settings.fullScreenSupportEnabled: true
    settings.playbackRequiresUserGesture: false

    userScripts.collection: [
        {
            name: "QWebChannel",
            sourceUrl: "qrc:///qtwebchannel/qwebchannel.js", // Shipped with Qt WebChannel
            injectionPoint: WebEngineScript.DocumentReady,
            worldId: WebEngineScript.ApplicationWorld
        },
        {
            name: "FocusTracker",
            sourceUrl: Qt.resolvedUrl("qrc:/scripts/focustracker.js"),
            injectionPoint: WebEngineScript.DocumentReady,
            worldId: WebEngineScript.ApplicationWorld
        },
        {
            name: "FocusStyle",
            injectionPoint: WebEngineScript.DocumentReady,
            worldId: WebEngineScript.ApplicationWorld,
            sourceCode: `(function () {
                const style = document.createElement("style");
                style.textContent = ":focus-visible { outline: 4px solid ${Kirigami.Theme.highlightColor} !important; outline-offset: 2px !important; border-radius: 4px; }";
                (document.head || document.documentElement).appendChild(style);
            })()`
        }
    ]

    onCurrentChanged: {
        if (current && url.toString().length === 0 && initialUrl.toString().length > 0) {
            url = initialUrl;
        }
    }

    Component.onCompleted: {
        initialUrl = tabs?.get(index)?.url ?? "";
        if (current && initialUrl.toString().length > 0) {
            url = initialUrl;
        }
    }

    onUrlChanged: {
        if (url.toString().length > 0) {
            updateTab("url", url.toString());
        }
    }
    onTitleChanged: updateTab("title", title)
    onIconSourceChanged: updateTab("iconUrl", iconSource.toString())

    onNewWindowRequested: request => {
        // HACK: prevent auto open tabs
        if (!request.userInitiated || !window) {
            window?.showMessage(i18n("Blocked a pop-up window"), "dialog-information");
            return;
        }
        window.newTab("");
        const view = window.browserPage.currentView;
        if (view) {
            request.openIn(view);
        }
        window.showBrowser();
    }

    onFullScreenRequested: request => request.accept()

    // TODO: context menus need mouse, do we need to support it?
    onContextMenuRequested: request => request.accepted = true

    onRenderProcessTerminated: (status, exitCode) => {
        if (status === WebEngineView.NormalTerminationStatus) {
            return;
        }
        if (crashTimer.running) {
            window?.showMessage(i18n("This page keeps crashing, so it was stopped"), "dialog-warning");
            return;
        }
        crashTimer.start();
        reloadTimer.start();
    }

    Timer {
        id: reloadTimer
        interval: 500
        onTriggered: root.reload()
    }

    Timer {
        id: crashTimer
        interval: 30 * 1000
    }

    WebChannel {
        id: channel
        registeredObjects: [bridge]
    }

    QtObject {
        id: bridge

        property bool editing: false

        WebChannel.id: "page"
    }
}
