/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
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
import "code/BookmarkStorage.js" as BookmarkStorage
import Aura 1.0 as Aura
import "code/Utils.js" as Utils

Controls.Popup {
    id: bookmarkPopupArea
    property bool editMode: false
    property alias model: delegateFilter.model
    property var genericModel
    property alias bookmarkStack: bookmarkManagerStackLayout.currentIndex
    property var preBookmarkName
    property var preBookmarkUrl
    width: parent.width / 2
    height:  parent.height / 2
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    dim: true

    Controls.Overlay.modeless: Rectangle {
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.77)
    }

    background: Rectangle {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        border.color: "black"
    }

    onPreBookmarkNameChanged: {
        nameFieldChild.text = preBookmarkName
    }
    onPreBookmarkUrlChanged: {
        urlFieldChild.text = preBookmarkUrl
    }

    function deleteBookmarkByRowId(id){
        BookmarkStorage.dbDeleteRow(id);
        genericModel.clear();
        delegateFilter.model.clear();
        BookmarkStorage.dbReadAll();
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
        if(bookmarkStack == 0){
            bookmarkSearchField.forceActiveFocus()
        } else {
            nameField.forceActiveFocus()
        }
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

            onClicked: {
                Aura.NavigationSoundEffects.playClickedSound()
                if(removeModeBox.checked){
                    deleteBookmarkByRowId(id);
                } else {
                    createTab(recent_url);
                    bookmarkPopupArea.close();
                }
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
                var bookmarks = genericModel.get(i, "recent_name");
                var bookmarkName = bookmarks.recent_name
                if (bookmarkName.indexOf(bookmarkSearchFieldChild.text) != -1){
                    items.addGroups(i, 1, "filterGroup");}
                else {
                    items.removeGroups(i, 1, "filterGroup");
                }
            }
        }
    }

    StackLayout {
        id: bookmarkManagerStackLayout
        currentIndex: 0
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing

        Item {
            width: parent.width
            height: parent.height

            RowLayout {
                id: headerAreaBMLPg1
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Kirigami.Heading {
                    id: bookmarkMgrHeading
                    level: 1
                    text: i18n("Bookmarks Manager")
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
                id: headrSeptBml
                anchors.top: headerAreaBMLPg1.bottom
                width: parent.width
                height: 1
            }

            ColumnLayout {
                anchors.top: headrSeptBml.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4

                    Item {
                        id: bookmarkSearchField
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                        KeyNavigation.right: removeModeBox
                        KeyNavigation.down: bookmarksManagerListView
                        Keys.onEnterPressed: bookmarkSearchFieldChild.forceActiveFocus()

                        Controls.TextField {
                            id: bookmarkSearchFieldChild
                            anchors.fill: parent
                            placeholderText: i18n("Search Bookmarks")
                            color: Kirigami.Theme.textColor
                            background: Rectangle {
                                Kirigami.Theme.colorSet: Kirigami.Theme.View
                                color: Kirigami.Theme.backgroundColor
                                border.color: bookmarkSearchField.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
                                border.width: 1
                            }
                            onTextChanged:  {
                                delegateFilter.applyFilter()
                            }
                            onAccepted: {
                                bookmarkSearchField.forceActiveFocus()
                            }
                        }

                        Keys.onReturnPressed: {
                            bookmarkSearchFieldChild.forceActiveFocus();
                        }

                        Keys.onPressed: {
                            playKeySounds(event)
                        }
                    }

                    Controls.CheckBox {
                        id: removeModeBox
                        checkable: true
                        checked: false
                        text: i18n("Remove Mode")
                        KeyNavigation.right: addModeBox
                        KeyNavigation.left: bookmarkSearchField
                        KeyNavigation.down: bookmarksManagerListView
                        Kirigami.Theme.inherit: false
                        Kirigami.Theme.colorSet: Kirigami.Theme.View

                        Keys.onReturnPressed: {
                            checked = !checked
                        }

                        Keys.onPressed: {
                            playKeySounds(event)
                        }
                    }

                    Controls.Button {
                        id: addModeBox
                        text: i18n("Add")
                        palette.buttonText: Kirigami.Theme.textColor
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                        KeyNavigation.left: removeModeBox
                        KeyNavigation.down: bookmarksManagerListView

                        background: Rectangle {
                            color: addModeBox.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                            border.color: Kirigami.Theme.disabledTextColor
                            radius: 20
                        }

                        onClicked: {
                            bookmarkManagerStackLayout.currentIndex = 1
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
                    id: bookmarksManagerListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: delegateFilter
                    clip: true
                    keyNavigationEnabled: true
                    KeyNavigation.up: bookmarkSearchField

                    Keys.onPressed: {
                        playKeySounds(event)
                    }
                }
            }
        }

        Item {
            id: addBookMarkLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            onVisibleChanged: {
                if(visible){
                    nameField.forceActiveFocus()
                }
            }

            RowLayout {
                id: headerAreaBML
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Kirigami.Heading {
                    id: bookmarkAddHeading
                    level: 1
                    text: i18n("Add Bookmark")
                    color: Kirigami.Theme.textColor
                    width: parent.width
                    horizontalAlignment: Qt.AlignLeft
                    Layout.alignment: Qt.AlignLeft
                }

                Controls.Label {
                    id: backbtnlabel
                    text: i18n("Press 'esc' or the [←] Back button to close")
                    color: Kirigami.Theme.textColor
                    Layout.alignment: Qt.AlignRight
                }
            }

            Kirigami.Separator {
                id: headrSept
                anchors.top: headerAreaBML.bottom
                width: parent.width
                height: 1
            }

            RowLayout {
                id: nameRow
                anchors.top: headrSept.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 4

                Kirigami.Heading {
                    level: 3
                    text: i18n("Name: ")
                    color: Kirigami.Theme.textColor
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                Item {
                    id: nameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.down: urlField

                    Keys.onReturnPressed: {
                        nameFieldChild.forceActiveFocus()
                    }

                    Keys.onPressed: {
                        playKeySounds(event)
                    }

                    Controls.TextField {
                        id: nameFieldChild
                        anchors.fill: parent
                        color: Kirigami.Theme.textColor
                        background: Rectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            color: Kirigami.Theme.backgroundColor
                            border.color: nameField.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
                            border.width: 1
                        }

                        Keys.onPressed: {
                            playKeySounds(event)
                        }

                        onAccepted: {
                            Aura.NavigationSoundEffects.playClickedSound()
                            urlField.forceActiveFocus()
                        }
                    }
                }
            }

            RowLayout {
                id: urlRow
                anchors.top: nameRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 4

                Kirigami.Heading {
                    level: 3
                    text: i18n("Url: ")
                    color: Kirigami.Theme.textColor
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                Item {
                    id: urlField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.up: nameField
                    KeyNavigation.down: catField

                    Keys.onReturnPressed: {
                        urlFieldChild.forceActiveFocus()
                    }

                    Keys.onPressed: {
                        playKeySounds(event)
                    }

                    Controls.TextField {
                        id: urlFieldChild
                        anchors.fill: parent
                        color: Kirigami.Theme.textColor
                        background: Rectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            color: Kirigami.Theme.backgroundColor
                            border.color: urlField.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
                            border.width: 1
                        }

                        Keys.onPressed: {
                            playKeySounds(event)
                        }

                        onAccepted: {
                            Aura.NavigationSoundEffects.playClickedSound()
                            catRow.forceActiveFocus()
                        }
                    }
                }
            }

            RowLayout {
                id: catRow
                anchors.top: urlRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 4
                Kirigami.Heading {
                    level: 3
                    text: i18n("Category: ")
                    color: Kirigami.Theme.textColor
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                Item {
                    id: catField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    KeyNavigation.up: urlField
                    KeyNavigation.down: addBookMarkBtn

                    Keys.onReturnPressed: {
                        catFieldChild.forceActiveFocus()
                    }

                    Keys.onPressed: {
                        playKeySounds(event)
                    }

                    Controls.ComboBox {
                        id: catFieldChild
                        model: ["News", "Entertainment", "Infotainment", "General"]
                        currentIndex: 3
                        anchors.fill: parent
                        palette.buttonText: Kirigami.Theme.textColor
                        
                        background: Rectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.View
                            color: Kirigami.Theme.backgroundColor
                            border.color: catField.activeFocus ? Kirigami.Theme.hoverColor : Kirigami.Theme.disabledTextColor
                            border.width: 1
                        }

                        Keys.onReturnPressed: {
                            addBookMarkBtn.forceActiveFocus()
                        }

                        Keys.onPressed: {
                            playKeySounds(event)
                        }
                    }
                }
            }

            RowLayout {
                id: addBookMarkBtnRow
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Kirigami.Units.gridUnit * 3

                Controls.Button {
                    id: backBookMarkBtn
                    text: i18n("Bookmarks")
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    KeyNavigation.right: addBookMarkBtn
                    KeyNavigation.up: nameField
                    palette.buttonText: Kirigami.Theme.textColor

                    background: Rectangle {
                        color: backBookMarkBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 2
                    }
                    onClicked: {
                        Aura.NavigationSoundEffects.playClickedSound()
                        bookmarkManagerStackLayout.currentIndex = 0
                        bookmarkSearchField.forceActiveFocus()
                    }
                    Keys.onReturnPressed: {
                        clicked()
                    }
                    Keys.onPressed: {
                        playKeySounds(event)
                    }
                }

                Controls.Button {
                    id: addBookMarkBtn
                    text: i18n("Add")
                    palette.buttonText: Kirigami.Theme.textColor

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    KeyNavigation.left: backBookMarkBtn
                    KeyNavigation.up: nameField
                    background: Rectangle {
                        color: addBookMarkBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                        border.color: Kirigami.Theme.disabledTextColor
                        radius: 2
                    }
                    onClicked: {
                        Aura.NavigationSoundEffects.playClickedSound()
                        Utils.insertBookmarkToManager(urlFieldChild.text, nameFieldChild.text, catFieldChild.currentText)
                        bookmarkPopupArea.close()
                    }
                    Keys.onReturnPressed: {
                        clicked()
                    }
                    Keys.onPressed: {
                        playKeySounds(event)
                    }
                }
            }
        }
    }
}
