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

import QtQuick 2.10
import QtQuick.Window 2.10
import QtWebEngine 1.7
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.10 as Controls
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.0
import QtQuick.VirtualKeyboard 2.5
import "views" as Views
import "delegates" as Delegates
import "code/RecentStorage.js" as RecentStorage
import "code/BookmarkStorage.js" as BookmarkStorage
import "code/Utils.js" as Utils

Kirigami.Page {
    Layout.fillWidth: true
    Layout.fillHeight: true

    onFocusChanged: {
        if(focus){
            recentPagesView.forceActiveFocus()
        }
    }

    onVisibleChanged: {
        if(visible) {
           recentPagesModel.clear()
           RecentStorage.dbReadAll()
        }
    }

    Component.onCompleted: {
        recentPagesView.forceActiveFocus()
    }

    function checkURL(value) {
        var urlregex = new RegExp("^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$");
        if (urlregex.test(value)) {
            return (true);
        }
        return (false);
    }

    ListModel {
        id: recentPagesModel
        Component.onCompleted: RecentStorage.dbReadAll()
    }

    ListModel {
        id: bookmarksModel
        Component.onCompleted: BookmarkStorage.dbReadAll()
    }

    function insertRecentLink(url){
        var xzy = new XMLHttpRequest
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true

            Controls.Button {
                id: startPageMenuButton
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.right: startPageTabsButton
                KeyNavigation.down: searchandurlfield

                background: Rectangle {
                    color: startPageMenuButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                contentItem: Item {
                        Kirigami.Icon {
                            source: "application-menu"
                            anchors.centerIn: parent
                            width: Kirigami.Units.iconSizes.small
                            height: Kirigami.Units.iconSizes.small
                    }
                }

                onClicked: {
                    gDrawer.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Controls.Button {
                id: startPageTabsButton
                text: "Tabs"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.right: startPageHistoryButton
                KeyNavigation.left: startPageMenuButton
                KeyNavigation.down: searchandurlfield

                background: Rectangle {
                    color: startPageTabsButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                   tabBarView.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Controls.Button {
                id: startPageHistoryButton
                text: "History"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.left: startPageTabsButton
                KeyNavigation.right: startPageBookmarksButton
                KeyNavigation.down: searchandurlfield

                background: Rectangle {
                    color: startPageHistoryButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    historyTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Controls.Button {
                id: startPageBookmarksButton
                text: "Bookmarks"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.left: startPageHistoryButton
                KeyNavigation.right: startPageHelpButton
                KeyNavigation.down: searchandurlfield

                background: Rectangle {
                    color: startPageBookmarksButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    bookmarkTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Controls.Button {
                id: startPageHelpButton
                text: "Help"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignRight
                KeyNavigation.left: startPageBookmarksButton
                KeyNavigation.down: searchandurlfield

                background: Rectangle {
                    color: startPageHelpButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    helpTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Item {
                id: logoPageNameContainer
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight | Qt.AlignTop

                Image {
                    id: browserLogo
                    width: Kirigami.Units.iconSizes.large
                    height:  Kirigami.Units.iconSizes.large
                    source: Qt.resolvedUrl("./images/logo-small.png")
                    anchors.right: browserHeading.left
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    anchors.verticalCenter: browserHeading.verticalCenter
                }

                Kirigami.Heading {
                    id: browserHeading
                    text: "Aura Browser - Start Page"
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right
                    font.bold: true
                }
            }
        }

        Rectangle {
            id: searchandurlfield
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4
            color: activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
            border.color: Kirigami.Theme.disabledTextColor
            radius: 20
            KeyNavigation.down: recentPagesView
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Qt.rgba(0,0,0,0.6)
            }

            RowLayout {
                anchors.centerIn: parent
                height: parent.height
                anchors.margins: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    source: "search"
                }

                Kirigami.Heading {
                    level: 2
                    text: "Search or type url"
                    font.bold: true
                }
            }

            Keys.onReturnPressed: {
                urlEntryDrawer.open()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: urlEntryDrawer.open()
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        Views.LabelView  {
            title: "Recent Pages"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: recentPagesModel.count > 0 ? 1 : 0

            Controls.Button {
                id: clearRecentBtn
                text: "Clear"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignRight
                KeyNavigation.up: searchandurlfield
                KeyNavigation.right: recentPagesView

                background: Rectangle {
                    color: clearRecentBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    RecentStorage.dbClearTable()
                }

                Keys.onReturnPressed: {
                    clicked();
                }
            }

            Views.TileView {
                id: recentPagesView
                clip: true
                model: recentPagesModel
                focus: true
                navigationUp: searchandurlfield
                navigationDown: bookmarksView
                KeyNavigation.left: clearRecentBtn
                delegate: Delegates.RecentDelegate{}
            }
        }

        Views.LabelView  {
            title: "Bookmarks"
        }

        FocusScope {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Views.TileViewGrid {
                id: bookmarksView
                clip: true
                model: bookmarksModel
                KeyNavigation.up: recentPagesView
                focus: false
                delegate: Delegates.BookmarkDelegate{}
            }
        }
    }

    Kirigami.OverlayDrawer {
        id: urlEntryDrawer
        width: parent.width
        height: parent.height
        edge: Qt.TopEdge
        dragMargin: 0
        dim: true

        onOpened: {
            urlEntrie.forceActiveFocus()
        }

        Item {
            id: entryLayout
            anchors.fill: parent

            RowLayout {
                id: headerAreaURLandSearchField
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Kirigami.Heading {
                    id: urlSearchFieldLabel
                    level: 1
                    text: "Enter URL / Search Term"
                    width: parent.width
                    horizontalAlignment: Qt.AlignLeft
                    Layout.alignment: Qt.AlignLeft
                }

                Controls.Label {
                    id: urlSearchFieldBackBtnLabel
                    text: "Press 'esc' or the [←] Back button to close"
                    Layout.alignment: Qt.AlignRight
                }
            }

            Kirigami.Separator {
                id: urlSearchFieldheaderSept
                anchors.top: headerAreaURLandSearchField.bottom
                width: parent.width
                height: 1
            }

            Controls.TextField {
                id: urlEntrie
                anchors.top: urlSearchFieldheaderSept.bottom
                anchors.topMargin: Kirigami.Units.largeSpacing
                width: parent.width
                height: Kirigami.Units.gridUnit * 5
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                placeholderText: "Enter Search Term or URL"
                background: Rectangle {
                    color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    border.width: 1
                }

                onAccepted: {
                    //urlEntryDrawer.close()
                    //root.showStack = 1
                    var setUrl = checkURL(urlEntrie.text)
                    if(setUrl){
                        //root.showUrl = urlEntrie.text
                        createTab(urlEntrie.text)
                    } else {
                        //root.showUrl = "https://www.google.com/search?q=" + urlEntrie.text
                        var searchTypeUrl = "https://www.google.com/search?q=" + urlEntrie.text
                        createTab(searchTypeUrl)
                    }
                    urlEntryDrawer.close()
                }
            }

            InputPanel {
                id: inputPanel
                y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }

    BookmarkManager{
        id: bookmarkTabManager
        model: bookmarksModel
        genericModel: bookmarksModel
    }

    HistoryManager {
        id: historyTabManager
        model: recentPagesModel
        genericModel: recentPagesModel
    }

    HelpTab{
        id: helpTabManager
    }
}
