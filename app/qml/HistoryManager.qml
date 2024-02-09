/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as Controls
import QtQml.Models 2.12
import QtQuick.LocalStorage 2.12
import QtQuick.VirtualKeyboard 2.4
import Aura 1.0 as Aura
import "code/RecentStorage.js" as RecentStorage
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

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
        delegate: Controls.ItemDelegate {
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
                        color: Kirigami.Theme.textColor
                    }
                }

                Controls.Label {
                    text: model.recent_name
                    Layout.preferredWidth: parent.width / 2
                    elide: Text.ElideRight
                    color: Kirigami.Theme.textColor
                }

                Controls.Label {
                    text: model.recent_url
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                }
            }

            onClicked: (mouse)=> {
                Aura.NavigationSoundEffects.playClickedSound()
                createTab(recent_url);
                historyPopupArea.close();
            }

            Keys.onReturnPressed: (event)=> {
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
                text: i18n("History")
                color: Kirigami.Theme.textColor
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Controls.Label {
                id: backbtnlabelHeading
                text: i18n("Press 'esc' or the [←] Back button to close")
                color: Kirigami.Theme.textColor
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
                        placeholderText: i18n("Search History")
                        color: Kirigami.Theme.textColor
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

                    Keys.onReturnPressed: (event)=> {
                        historySearchFieldChild.forceActiveFocus();
                    }

                    Keys.onPressed: (event)=> {
                        playKeySounds(event)
                    }
                }

                Controls.Button {
                    id: clearHistoryButton
                    text: i18n("Clear History")
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 8
                    KeyNavigation.left: historySearchField
                    KeyNavigation.down: historyManagerListView
                    palette.buttonText: Kirigami.Theme.textColor

                    background: Rectangle {
                        color: clearHistoryButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 20
                    }

                    onClicked: (mouse)=> {
                        RecentStorage.dbClearTable();
                    }
                    Keys.onReturnPressed: (event)=> {
                        RecentStorage.dbClearTable();
                    }

                    Keys.onPressed: (event)=> {
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

                Keys.onPressed: (event)=> {
                    playKeySounds(event)
                }
            }

            Kirigami.Heading {
                level: 3
                text: i18n("No Recent History")
                color: Kirigami.Theme.textColor
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: genericModel.count == 0 ? 1 : 0
            }
        }
    }
}
