/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import Qt5Compat.GraphicalEffects

Rectangle {
    id: containerA
    implicitHeight: autoCompListView.implicitHeight
    color: "transparent"
    property QtObject model: undefined
    property alias suggestionsModel: filterItem.model
    property int count: filterItem.model.count
    property alias filter: filterItem.filter
    property alias property: filterItem.property
    signal itemSelected(variant item)

    onActiveFocusChanged: {
        if(activeFocus){
            autoCompListView.forceActiveFocus()
        }
    }

    function filterMatchesLastSuggestion() {
        return suggestionsModel.count == 1 && suggestionsModel.get(0).name === filter
    }

    SuggestionsLogic {
        id: filterItem
        sourceModel: containerA.model
    }

    visible: filter.length > 0 && suggestionsModel.count > 0 && !filterMatchesLastSuggestion()

    Kirigami.Heading {
        id: suggstheading
        level: 1
        text: i18n("Suggestions:")
        color: Kirigami.Theme.textColor
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.smallSpacing
        horizontalAlignment: Qt.AlignLeft
    }

    ListView {
        id: autoCompListView
        anchors.top: suggstheading.bottom
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: containerA.model
        keyNavigationEnabled: true
        KeyNavigation.up: localurlEntrie
        highlightFollowsCurrentItem: true
        snapMode: ListView.SnapToItem
        implicitHeight: contentItem.childrenRect.height
        verticalLayoutDirection: ListView.TopToBottom
        clip: true
        delegate: Item {
            id: delegateItem
            property bool keyboardSelected: autoCompListView.selectedIndex === suggestion.index
            property bool selected: itemMouseArea.containsMouse
            property variant suggestion: model

            height: textComponent.height + Kirigami.Units.gridUnit * 2
            width: containerA.width

            Item{
                anchors.fill:parent
                focus: false

                Rectangle{
                    id: autdelRect
                    color: delegateItem.selected || delegateItem.activeFocus ? Qt.darker(Kirigami.Theme.textColor, 1.2) : Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
                    width: parent.width
                    height: textComponent.height + Kirigami.Units.gridUnit * 2

                    Rectangle {
                        id : smallIconV
                        color: model.randcolor
                        width: Kirigami.Units.gridUnit * 2
                        height: Kirigami.Units.gridUnit * 2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Kirigami.Units.gridUnit * 0.35
                    }

                    Kirigami.Separator {
                        id: innerDelegateRectDividerLine
                        anchors {
                            left: smallIconV.right
                            leftMargin: Kirigami.Units.gridUnit * 0.35
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: 1
                    }

                    Text {
                        id: textComponent
                        anchors.left: innerDelegateRectDividerLine.right
                        anchors.leftMargin: Kirigami.Units.gridUnit * 0.35
                        color: delegateItem.selected ? Qt.darker(Kirigami.Theme.backgroundColor, 1.2) : Qt.darker(Kirigami.Theme.textColor, 1.2)
                        text: model.name;
                        width: parent.width - 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: containerA.itemSelected(delegateItem.suggestion)
                    }

                    Kirigami.Separator {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 1
                    }
                }
            }

            Keys.onReturnPressed:  {
                containerA.itemSelected(delegateItem.suggestion)
            }
        }
        ScrollBar.vertical: ScrollBar { }
    }
}
