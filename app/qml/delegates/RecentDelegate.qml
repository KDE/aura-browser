/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import Qt5Compat.GraphicalEffects

Controls.Control {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    readonly property ListView listView: ListView.view

    z: listView.currentIndex == index ? 2 : 0

    leftPadding: background.extraMargin
    topPadding: background.extraMargin
    rightPadding: background.extraMargin
    bottomPadding: background.extraMargin

    background: Item {
        id: background
        property real extraMargin:  Math.round(listView.currentIndex == index && delegate.activeFocus ? -Kirigami.Units.gridUnit/2 : Kirigami.Units.gridUnit/2)
        Behavior on extraMargin {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: frame
            anchors {
                fill: parent
                margins: background.extraMargin
            }
            color: Kirigami.Theme.backgroundColor
            width: listView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - Kirigami.Units.gridUnit
            height: listView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - Kirigami.Units.gridUnit
            opacity: 0.8
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Qt.rgba(0,0,0,0.6)
            }
        }
    }
    
    contentItem: ColumnLayout {
        spacing: 0
        Rectangle {
            id: bgImgIcon
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - label.height
            color: model.rand_color

            Kirigami.Heading {
                anchors.centerIn: parent
                text: model.recent_name.substring(0,1)
                font.bold: true
                color: Kirigami.Theme.textColor
            }
        }

        Kirigami.Heading {
            id: label
            visible: text.length > 0
            level: 3
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            elide: Text.ElideRight
            text: model.recent_name
            color: Kirigami.Theme.textColor
        }
    }

    Keys.onReturnPressed: (event)=> {
        urlEntryDrawer.close()
        createTab(model.recent_url)
    }

    MouseArea {
        id: mouseAreaRecent
        anchors.fill: delegate
        onClicked: (mouse)=> {
            urlEntryDrawer.close()
            createTab(model.recent_url)
        }
    }
}
