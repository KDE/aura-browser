/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.10
import QtQuick.Controls 2.10 as Controls
import QtQuick.Layouts 1.3
import Aura 1.0 as Aura
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Controls.Control {
    id: delegate

    implicitWidth: gridView.cellWidth
    implicitHeight: gridView.cellHeight

    readonly property GridView gridView: GridView.view

    z: gridView.currentIndex == index ? 2 : 0

    leftPadding: background.extraMargin
    topPadding: background.extraMargin
    rightPadding: background.extraMargin
    bottomPadding: background.extraMargin

    background: Item {
        id: background
        property real extraMargin:  Math.round(gridView.currentIndex == index && delegate.activeFocus ? -Kirigami.Units.gridUnit/2 : Kirigami.Units.gridUnit/2)
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
            width: gridView.currentIndex == index && delegate.activeFocus ? parent.width : parent.width - Kirigami.Units.gridUnit
            height: gridView.currentIndex == index && delegate.activeFocus ? parent.height : parent.height - Kirigami.Units.gridUnit
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
        Aura.NavigationSoundEffects.playClickedSound()
        urlEntryBox.close()
        createTab(model.recent_url)
    }

    MouseArea {
        id: mouseAreaRecent
        anchors.fill: delegate
        onClicked: (mouse)=> {
            Aura.NavigationSoundEffects.playClickedSound()
            urlEntryBox.close()
            createTab(model.recent_url)
        }
    }
}
