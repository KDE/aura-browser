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
            color: listView.currentIndex == index && delegate.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
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
                color: Kirigami.Theme.textColor
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
            color: Kirigami.Theme.textColor
        }
    }

    Keys.onReturnPressed: (event)=> {
        switchToTab(index);
        if(index > 0) {
            keyFilter.startFilter();
        }
    }

    onClicked: (mouse)=> {
        switchToTab(index);
        if(index > 0) {
            keyFilter.startFilter();
        }
    }
}
