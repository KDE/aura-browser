/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Layouts 1.12
import org.kde.kirigami as Kirigami

Rectangle {
    property bool isRequested: false
    property alias source: interactionLoader.source
    property alias interactionItem: interactionLoader.item

    visible: isRequested
    enabled: isRequested
    width: parent.width
    height: isRequested ? Kirigami.Units.gridUnit * 4 : 0
    color: Kirigami.Theme.backgroundColor

    function setSource(interactionSource){
        interactionLoader.setSource(interactionSource)
    }

    Keys.onEscapePressed: (event)=> {
        isRequested = false;
    }

    Keys.onBackPressed: (event)=> {
        isRequested = false;
    }

    Loader {
       id: interactionLoader
       anchors.fill: parent
    }
}
