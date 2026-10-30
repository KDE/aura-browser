// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI

Rectangle {
    id: root

    property url iconUrl
    property string host
    property color siteColor: {
        let hash = 0;
        for (let i = 0; i < host.length; ++i) {
            hash = (hash * 31 + host.charCodeAt(i)) | 0;
        }
        return Qt.hsva((hash >>> 0) % 360 / 360, 110 / 255, 150 / 255, 1);
    }
    property bool highlighted: false

    radius: BigscreenUI.Units.cardCornerRadius
    border.width: highlighted ? BigscreenUI.Units.focusBorderWidth : 0
    border.color: Kirigami.Theme.highlightColor
    gradient: Gradient {
        GradientStop { position: 0; color: Qt.lighter(root.siteColor, 1.25) }
        GradientStop { position: 1; color: Qt.darker(root.siteColor, 1.35) }
    }

    Rectangle {
        id: badge

        anchors.centerIn: parent
        width: Math.round(Math.min(parent.width, parent.height) * 0.35)
        height: width
        radius: width * 0.2
        color: Qt.rgba(1, 1, 1, 0.95)

        Image {
            id: favicon

            anchors.centerIn: parent
            width: Math.round(parent.width * 0.55)
            height: width
            source: root.iconUrl
            sourceSize.width: width
            sourceSize.height: height
            smooth: true
            asynchronous: true
            visible: status === Image.Ready
        }

        BigscreenUI.Label {
            anchors.centerIn: parent
            visible: !favicon.visible
            text: root.host.length > 0 ? root.host.charAt(0).toUpperCase() : "?"
            font.pixelSize: Math.round(badge.height * 0.55)
            font.weight: Font.DemiBold
            color: root.siteColor
        }
    }
}
