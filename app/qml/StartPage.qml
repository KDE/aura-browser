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
import QtQuick.LocalStorage 2.12
import QtQuick.VirtualKeyboard 2.4
import Aura 1.0 as Aura
import "views" as Views
import "delegates" as Delegates
import "code/RecentStorage.js" as RecentStorage
import "code/BookmarkStorage.js" as BookmarkStorage
import "code/Utils.js" as Utils

Kirigami.Page {
    id: startPageComp
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
        BookmarkStorage.dbReadAll()
    }

    Connections {
        target: root
        onSettingsTabRequested: {
            settingsTabArea.open()
        }
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
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

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
                    Aura.NavigationSoundEffects.playClickedSound();
                    gDrawer.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: startPageTabsButton
                text: i18n("Tabs")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.right: startPageHistoryButton
                KeyNavigation.left: startPageMenuButton
                KeyNavigation.down: searchandurlfield
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor


                background: Rectangle {
                    color: startPageTabsButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                   Aura.NavigationSoundEffects.playClickedSound();
                   tabBarView.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: startPageHistoryButton
                text: i18n("History")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.left: startPageTabsButton
                KeyNavigation.right: startPageBookmarksButton
                KeyNavigation.down: searchandurlfield
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: startPageHistoryButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    historyTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: startPageBookmarksButton
                text: i18n("Bookmarks")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignLeft
                KeyNavigation.left: startPageHistoryButton
                KeyNavigation.right: startPageSettingsButton
                KeyNavigation.down: searchandurlfield
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: startPageBookmarksButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    bookmarkTabManager.bookmarkStack = 0
                    bookmarkTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: startPageSettingsButton
                text: i18n("Settings")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignRight
                KeyNavigation.left: startPageBookmarksButton
                KeyNavigation.right: startPageHelpButton
                KeyNavigation.down: searchandurlfield
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: startPageSettingsButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    settingsTabArea.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }

            Controls.Button {
                id: startPageHelpButton
                text: i18n("Help")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignRight
                KeyNavigation.left: startPageSettingsButton
                KeyNavigation.down: searchandurlfield
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: startPageHelpButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    helpTabManager.open()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
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
                    text: i18n("Aura Browser - Start Page")
                    color: Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 4

            Rectangle {
                id: searchandurlfield
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                color: activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 20
                KeyNavigation.down: recentPagesView
                KeyNavigation.right: micBtnLoader
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
                        text: i18n("Search or type url")
                        font.bold: true
                        color: Kirigami.Theme.textColor
                    }
                }

                Keys.onReturnPressed: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    urlEntryDrawer.open()
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Aura.NavigationSoundEffects.playClickedSound();
                        urlEntryDrawer.open()
                        urlEntrie.forceActiveFocus()
                    }
                }

                Keys.onPressed: {
                    playKeySounds(event)
                }
            }
            InputLoader {
                id: micBtnLoader
                Layout.preferredWidth: parent.width * 0.10
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                rootTarget: startPageComp
                KeyNavigation.left: searchandurlfield
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        Views.LabelView  {
            title: i18n("Recent Pages")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: recentPagesModel.count > 0 ? 1 : 0

            Controls.Button {
                id: clearRecentBtn
                text: i18n("Clear")
                Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                Layout.alignment: Qt.AlignRight
                KeyNavigation.up: searchandurlfield
                KeyNavigation.right: recentPagesView
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                palette.buttonText: Kirigami.Theme.textColor

                background: Rectangle {
                    color: clearRecentBtn.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: Kirigami.Theme.disabledTextColor
                    radius: 20
                }

                onClicked: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    RecentStorage.dbClearTable()
                }

                Keys.onReturnPressed: {
                    clicked();
                }

                Keys.onPressed: {
                    playKeySounds(event)
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
            title: i18n("Bookmarks")
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

    Controls.Popup {
        id: urlEntryDrawer
        width: parent.width * 0.8
        height: parent.height * 0.8
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        //closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnReleaseOutside
        dim: true
        padding: Kirigami.Units.largeSpacing

        onOpened: {
            urlEntrie.forceActiveFocus()
        }

        Controls.Overlay.modal: Rectangle {
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
        }

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8.0
                samples: 17
                color: Qt.rgba(0,0,0,0.6)
            }
        }
        
        contentItem: FocusScope {
            id: entryLayout

            RowLayout {
                id: headerAreaURLandSearchField
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right                
                anchors.margins: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    id: urlSearchFieldLabel
                    level: 1
                    text: i18n("Enter URL / Search Term")
                    width: parent.width
                    horizontalAlignment: Qt.AlignLeft
                    Layout.alignment: Qt.AlignLeft
                    color: Kirigami.Theme.textColor
                }

                Controls.Label {
                    id: urlSearchFieldBackBtnLabel
                    text: i18n("Press 'esc' or the [←] Back button to close")
                    Layout.alignment: Qt.AlignRight
                    color: Kirigami.Theme.textColor
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
                placeholderText: i18n("Enter Search Term or URL")
                color: Kirigami.Theme.textColor
                focus: true
                background: Rectangle {
                    color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                    border.color: urlEntrie.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                    border.width: 1
                }

                onAccepted: {
                    Aura.NavigationSoundEffects.playClickedSound();
                    var setUrl = checkURL(urlEntrie.text)
                    if(setUrl){
                        createTab(urlEntrie.text)
                    } else {
                        var searchTypeUrl
                        if(Aura.GlobalSettings.defaultSearchEngine == "Google"){
                            searchTypeUrl = "https://www.google.com/search?q=" + urlEntrie.text
                        } else if (Aura.GlobalSettings.defaultSearchEngine == "DDG") {
                            searchTypeUrl = "https://duckduckgo.com/?q=" + urlEntrie.text
                        }
                        createTab(searchTypeUrl)
                    }
                    urlEntryDrawer.close()
                }
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

    SettingsTab {
        id: settingsTabArea
    }
}
