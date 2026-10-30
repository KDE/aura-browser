// SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.bigscreen.ui as BigscreenUI
import org.kde.aura

import "utils.js" as Utils

BigscreenUI.MediaCard {
    id: root

    property url url
    property string title
    property url iconUrl
    property alias siteColor: tile.siteColor
    property bool current: false

    readonly property string host: Utils.siteHost(url)

    artworkWidth: Kirigami.Units.gridUnit * 14
    artworkHeight: Math.round(artworkWidth * 9 / 16)
    text: title.length > 0 ? title : (host || url.toString().replace(/^.*\//, ""))
    subtitle: title.length > 0 ? host : ""
    Accessible.description: current ? i18n("Current tab") : ""

    SiteTile {
        id: tile

        parent: root.artworkItem
        anchors.fill: parent
        visible: root.artworkItem.status !== Image.Ready
        iconUrl: root.iconUrl
        host: root.host
        highlighted: root.activeFocus
    }

    Rectangle {
        id: currentTabOutline
        parent: root.artworkItem
        z: 1
        anchors.fill: parent
        visible: root.current && !root.activeFocus
        radius: BigscreenUI.Units.cardCornerRadius
        color: "transparent"
        border.width: Math.max(1, Math.round(BigscreenUI.Units.focusBorderWidth / 2))
        border.color: Qt.alpha(Kirigami.Theme.highlightColor, 0.7)
    }

    BigscreenUI.Badge {
        parent: root.artworkItem
        z: 1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Kirigami.Units.largeSpacing
        visible: root.current
        text: i18nc("@info:status the tab being shown", "Current")
        Accessible.ignored: true
    }
}
