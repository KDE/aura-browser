/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.10
import QtQuick.Controls 2.10 as Controls
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.11 as Kirigami

Controls.TabButton {
    id: delegate

    implicitWidth: listView.cellWidth
    implicitHeight: listView.height

    readonly property ListView listView: ListView.view
    property var randColor: model.rand_color
    property bool isRemovable: model.removable
    property var tabName

    z: listView.currentIndex == index ? 2 : 0

    onTabNameChanged: {
           label.text = tabName
    }

    background: Item {
        id: background

        Rectangle {
            id: frame
            anchors {
                fill: parent
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
        ShaderEffectSource {
            id: bgImgIcon
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height - label.height

            sourceRect: Qt.rect(0, 0, width * 2, height * 2)
            sourceItem: {
                auraStack.itemAt(index, 0);
            }

            Kirigami.Heading {
                anchors.centerIn: parent
                text: model.pageName.replace(/(^\w+:|^)\/\//, '').substring(0,1)
                font.bold: true
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
            text: model.pageName
        }
    }

    Keys.onReturnPressed: {
        console.log("hereinClick2")
        switchToTab(index);
    }

    onClicked: {
        console.log("hereinClick")
        switchToTab(index);
    }
}
