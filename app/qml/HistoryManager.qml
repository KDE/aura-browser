/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
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

import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12 as Controls
import QtGraphicalEffects 1.0
import QtQml.Models 2.12
import QtQuick.LocalStorage 2.12
import QtQuick.VirtualKeyboard 2.4
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage

Controls.Popup {
    id: historyPopupArea
    property alias model: delegateFilter.model
    property var genericModel
    width: parent.width / 2
    height:  parent.height / 2
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    padding: Kirigami.Units.largeSpacing
    dim: true

    Controls.Overlay.modeless: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.77)
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        border.color: "black"
    }

    function deleteAllHistory(){
    }

    function playKeySounds(event){
        switch (event.key) {
            case Qt.Key_Down:
            case Qt.Key_Right:
            case Qt.Key_Left:
            case Qt.Key_Up:
            case Qt.Key_Tab:
            case Qt.Key_Backtab:
                Aura.NavigationSoundEffects.playMovingSound();
                break;
            default:
                break;
        }
    }

    onOpened: {
        historySearchField.forceActiveFocus()
    }

    DelegateModel {
        id: delegateFilter
        delegate: Kirigami.AbstractListItem {
            contentItem: RowLayout {
                id: layout
                spacing: Kirigami.Units.largeSpacing
                Rectangle {
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    color: model.rand_color;

                    Controls.Label {
                        text: model.recent_name.substring(0,1);
                        anchors.centerIn: parent
                    }
                }

                Controls.Label {
                    text: model.recent_name
                    Layout.preferredWidth: parent.width / 2
                    elide: Text.ElideRight
                }

                Controls.Label {
                    text: model.recent_url
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }
            }

            onClicked: {
                Aura.NavigationSoundEffects.playClickedSound()
                createTab(recent_url);
                historyPopupArea.close();
            }

            Keys.onReturnPressed: {
                clicked();
            }
        }
        groups: [
            DelegateModelGroup {
                name: "filterGroup"; includeByDefault: true
            }
        ]
        filterOnGroup: "filterGroup"

        function applyFilter(){
            var numberOfFiles = genericModel.count;
            for (var i = 0; i < numberOfFiles; i++){
                var histories = genericModel.get(i, "recent_name");
                var historiesName = histories.recent_name
                if (historiesName.indexOf(historySearchFieldChild.text) != -1){
                    items.addGroups(i, 1, "filterGroup");}
                else {
                    items.removeGroups(i, 1, "filterGroup");
                }
            }
        }
    }

    Item {
       anchors.fill: parent

        RowLayout {
            id: headerAreaHML
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Kirigami.Heading {
                id: historyMgrHeading
                level: 1
                text: "History"
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Controls.Label {
                id: backbtnlabelHeading
                text: "Press 'esc' or the [←] Back button to close"
                Layout.alignment: Qt.AlignRight
            }
        }

        Kirigami.Separator {
            id: headrSeptHml
            anchors.top: headerAreaHML.bottom
            width: parent.width
            height: 1
        }

        ColumnLayout {
            anchors.top: headrSeptHml.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                Layout.alignment: Qt.AlignTop

                Item {
                    id: historySearchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.right: clearHistoryButton
                    KeyNavigation.down: historyManagerListView
                    Keys.onEnterPressed: historySearchFieldChild.forceActiveFocus()

                    Controls.TextField {
                        id: historySearchFieldChild
                        anchors.fill: parent
                        placeholderText: "Search History"
                        background: Rectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            color: Kirigami.Theme.backgroundColor
                            border.color: historySearchField.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
                            border.width: 1
                        }
                        onTextChanged:  {
                            delegateFilter.applyFilter()
                        }
                        onAccepted: {
                            historySearchField.forceActiveFocus()
                        }
                    }

                    Keys.onReturnPressed: {
                        historySearchFieldChild.forceActiveFocus();
                    }

                    Keys.onPressed: {
                        playKeySounds(event)
                    }
                }

                Controls.Button {
                    id: clearHistoryButton
                    text: "Clear History"
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                    KeyNavigation.left: historySearchField
                    KeyNavigation.down: historyManagerListView

                    background: Rectangle {
                        color: clearHistoryButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 20
                    }

                    onClicked: {
                        RecentStorage.dbClearTable();
                    }
                    Keys.onReturnPressed: {
                        clicked()
                    }

                    Keys.onPressed: {
                        playKeySounds(event)
                    }
                }
            }

            ListView {
                id: historyManagerListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: delegateFilter
                clip: true
                keyNavigationEnabled: true
                KeyNavigation.up: historySearchField
                visible: genericModel.count > 0 ? 1 : 0
                enabled: genericModel.count > 0 ? 1 : 0

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Kirigami.Heading {
                level: 3
                text: "No Recent History"
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: genericModel.count == 0 ? 1 : 0
            }
        }
    }
}
