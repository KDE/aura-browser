// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.aura

Item {
    id: root

    required property PointerController controller

    x: controller.position.x
    y: controller.position.y
    opacity: idleTimer.running || controller.moving ? 1 : 0.6
    onVisibleChanged: idleTimer.restart()

    Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.longDuration } }

    Connections {
        target: root.controller
        function onPositionChanged() {
            idleTimer.restart();
        }
    }

    Timer {
        id: idleTimer
        interval: 3000
    }

    Rectangle {
        readonly property real size: Kirigami.Units.gridUnit * 2

        x: -width / 2
        y: -height / 2
        width: size
        height: size
        radius: width / 2
        scale: root.controller.pressed ? 0.75 : 1
        color: Qt.rgba(0, 0, 0, 0.45)

        Behavior on scale { NumberAnimation { duration: Kirigami.Units.shortDuration } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: width / 2
            color: Qt.alpha(Kirigami.Theme.highlightColor, 0.55)
            border.width: 3
            border.color: "white"
        }

        Rectangle {
            anchors.centerIn: parent
            width: Kirigami.Units.smallSpacing * 2
            height: width
            radius: width / 2
            color: "white"
        }
    }
}
