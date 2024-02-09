/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/



import QtQuick 2.10
import QtQuick.Window 2.10
import QtWebEngine 1.7
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami
import Qt5Compat.GraphicalEffects

Kirigami.Heading {
    id: header
    property string title
    text: title
    color: Kirigami.Theme.textColor
    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: Qt.rgba(0,0,0,0.6)
    }
} 
