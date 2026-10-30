// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtWebEngine

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI
import org.kde.aura

import "utils.js" as Utils

FocusScope {
    id: root

    property bool active: false

    readonly property Main window: T.ApplicationWindow.window as Main

    readonly property WebView currentView: {
        const index = window?.currentTab ?? -1;
        return views.count > 0 && index >= 0 ? views.itemAt(index) as WebView : null;
    }

    function pauseMedia() {
        currentView?.pauseMedia();
    }

    function setPointerNavigation(enabled: bool) {
        if (!currentView || currentView.pointerNavigation === enabled) {
            return;
        }
        currentView.pointerNavigation = enabled;
        if (enabled) {
            window.showMessage(i18n("Pointer: move with the arrows, press OK to click"), "input-mouse");
        } else {
            window.showMessage(i18n("Links: the arrows move between links"), "link");
        }
    }

    function focusPage() {
        currentView?.forceActiveFocus();
    }

    onActiveChanged: {
        if (active) {
            controls.close();
            focusPage();
        }
    }
    onCurrentViewChanged: {
        if (active && !controls.opened) {
            focusPage();
        }
    }

    BigscreenUI.BackHandler.enabled: active && !controls.opened && currentView !== null
    BigscreenUI.BackHandler.onActivated: {
        if (currentView.editing) { // back out of text field
            currentView.blurField();
        } else if (currentView.isFullScreen) { // back out of fullscreen content
            currentView.fullScreenCancelled();
        } else { // open controls
            controls.open();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Item {
        id: viewContainer

        anchors.fill: parent

        // Shrink back while the controls are open
        transform: Scale {
            origin.x: viewContainer.width / 2
            origin.y: 0
            xScale: controls.opened ? 0.9 : 1
            yScale: xScale

            Behavior on xScale {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        Repeater {
            id: views
            model: root.window?.tabs ?? null

            delegate: WebView {
                anchors.fill: parent
                current: index === root.window?.currentTab
                visible: current
                focus: current
                // Navigating from the controls (back, reload) shouldn't pull focus out from under them
                settings.focusOnNavigationEnabled: !controls.opened
                onPermissionRequested: permission => permissionDialog.ask(permission)
            }
        }
    }

    // Loading progress, along the top
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        height: Kirigami.Units.smallSpacing
        width: parent.width * (root.currentView?.loadProgress ?? 0) / 100
        color: Kirigami.Theme.highlightColor
        opacity: (root.currentView?.loading ?? false) && !controls.opened ? 1 : 0
        visible: opacity > 0

        Behavior on width { NumberAnimation { duration: Kirigami.Units.shortDuration } }
        Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }
    }

    PointerController {
        id: pointer

        target: root.currentView
        enabled: root.active && root.currentView !== null && root.currentView.pointerNavigation && !root.currentView.editing && !controls.opened
        speed: BrowserSettings.pointerSpeed
    }

    // The cursor controlled by arrow keys
    PointerCursor {
        controller: pointer
        visible: pointer.enabled && root.active
    }

    BrowserControls {
        id: controls

        anchors.fill: parent
        view: root.currentView
        onClosed: root.focusPage()
        onPointerNavigationToggled: root.setPointerNavigation(!root.currentView.pointerNavigation)
    }

    BigscreenUI.Dialog {
        id: permissionDialog

        property webEnginePermission permission
        property var pending: []

        function ask(request: webEnginePermission): void {
            if (opened || visible) {
                pending.push(request);
            } else {
                permission = request;
                open();
            }
        }

        readonly property string host: Utils.originHost(permission.origin)

        title: {
            switch (permission.permissionType) {
            case WebEnginePermission.PermissionType.MediaAudioCapture:
                return i18n("Let %1 use your microphone?", host);
            case WebEnginePermission.PermissionType.MediaVideoCapture:
                return i18n("Let %1 use your camera?", host);
            case WebEnginePermission.PermissionType.MediaAudioVideoCapture:
                return i18n("Let %1 use your camera and microphone?", host);
            case WebEnginePermission.PermissionType.DesktopVideoCapture:
            case WebEnginePermission.PermissionType.DesktopAudioVideoCapture:
                return i18n("Let %1 see your screen?", host);
            case WebEnginePermission.PermissionType.Notifications:
                return i18n("Let %1 show notifications?", host);
            case WebEnginePermission.PermissionType.Geolocation:
                return i18n("Let %1 know your location?", host);
            case WebEnginePermission.PermissionType.ClipboardReadWrite:
                return i18n("Let %1 use the clipboard?", host);
            default:
                return i18n("Let %1 use this feature?", host);
            }
        }
        standardButtons: T.Dialog.Ok | T.Dialog.Cancel
        openFocusItem: standardButton(T.Dialog.Ok)

        contentItem: BigscreenUI.Label {
            text: i18n("You can change your mind by clearing site data in the settings.")
            wrapMode: Text.Wrap
            color: Kirigami.Theme.disabledTextColor
        }

        Component.onCompleted: {
            standardButton(T.Dialog.Ok).text = i18n("Allow");
            standardButton(T.Dialog.Cancel).text = i18n("Don't Allow");
        }

        onAccepted: permission.grant()
        onRejected: permission.deny()
        onClosed: {
            if (pending.length > 0) {
                permission = pending.shift();
                open();
            } else {
                root.focusPage();
            }
        }
    }

    Shortcut {
        sequences: ["Menu", "F10"]
        enabled: root.active && root.currentView !== null
        onActivated: controls.opened ? controls.close() : controls.open()
    }
    Shortcut {
        sequences: ["Ctrl+L", "F6"]
        enabled: root.active
        onActivated: root.window.openAddress(root.currentView?.url.toString() ?? "", false)
    }
    Shortcut {
        sequences: [StandardKey.Refresh]
        enabled: root.active && root.currentView !== null
        onActivated: root.currentView.reload()
    }
    Shortcut {
        sequences: [StandardKey.ZoomIn]
        enabled: root.active && root.currentView !== null
        onActivated: root.currentView.zoomFactor = Math.min(3, root.currentView.zoomFactor + 0.1)
    }
    Shortcut {
        sequences: [StandardKey.ZoomOut]
        enabled: root.active && root.currentView !== null
        onActivated: root.currentView.zoomFactor = Math.max(0.5, root.currentView.zoomFactor - 0.1)
    }
    Shortcut {
        sequences: [StandardKey.AddTab]
        enabled: root.active
        onActivated: root.window.openAddress("", true)
    }
    Shortcut {
        sequences: [StandardKey.Close]
        enabled: root.active
        onActivated: root.window.closeTab(root.window.currentTab)
    }
    Shortcut {
        sequences: ["Media Play", "Media Pause", "Toggle Media Play/Pause"]
        enabled: root.active && root.currentView !== null
        context: Qt.ApplicationShortcut
        onActivated: root.currentView.togglePlayback()
    }
}
