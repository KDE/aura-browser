/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.15
import org.kde.kirigami 2.19 as Kirigami
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils
import Aura 1.0 as Aura
import QtQuick.VirtualKeyboard 2.15
import Qt5Compat.GraphicalEffects

Popup {
    id: webpageUrlEntryDrawer
    width: parent.width * 0.8
    height: parent.height * 0.8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    padding: Kirigami.Units.largeSpacing
    modal: true
    dim: true

    Overlay.modal: Rectangle {
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

    function autoAppend(model, getinputstring, setinputstring) {
        for(var i = 0; i < model.count; ++i)
            if (getinputstring(model.get(i))){
                return true
            }
        return null
    }

    function evalAutoLogic() {
        if (suggestionsBox.currentIndex === -1) {
        } else {
            suggestionsBox.complete(suggestionsBox.currentItem)
        }
    }

    onOpened: {
        localurlEntrie.forceActiveFocus()
    }

    ListModel {
        id: completionItems
    }

    contentItem: Item {
        id: entryLayout

        RowLayout {
            id: localHeaderAreaURLandSearchField
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                id: localUrlSearchFieldLabel
                level: 1
                text: i18n("Enter URL / Search Term")
                color: Kirigami.Theme.textColor
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                id: localUrlSearchFieldBackBtnLabel
                text: i18n("Press 'esc' or the [←] Back button to close")
                Layout.alignment: Qt.AlignRight
                color: Kirigami.Theme.textColor
            }
        }

        Kirigami.Separator {
            id: localUrlSearchFieldheaderSept
            anchors.top: localHeaderAreaURLandSearchField.bottom
            width: parent.width
            height: 1
        }

        TextField {
            id: localurlEntrie
            width: parent.width
            anchors.top: localUrlSearchFieldheaderSept.bottom
            anchors.topMargin: Kirigami.Units.largeSpacing
            height: Kirigami.Units.gridUnit * 5
            placeholderText: i18n("Enter Search Term or URL")
            color: Kirigami.Theme.textColor
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            background: Rectangle {
                color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: localurlEntrie.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            onAccepted: {
                var evaluateExist = webpageUrlEntryDrawer.autoAppend(completionItems, function(item) { return item.name === localurlEntrie.text }, localurlEntrie.text)
                console.log(evaluateExist)
                if(evaluateExist === null){
                    completionItems.append({"name": localurlEntrie.text, "randcolor": Utils.genRandomColor().toString()});
                }
                var setUrl = Utils.checkURL(localurlEntrie.text)
                if(setUrl){
                    webView.url = localurlEntrie.text
                } else {
                    var searchTypeUrl
                    if(Aura.GlobalSettings.defaultSearchEngine == "Google"){
                        searchTypeUrl = "https://www.google.com/search?q=" + localurlEntrie.text
                    } else if (Aura.GlobalSettings.defaultSearchEngine == "DDG") {
                        searchTypeUrl = "https://duckduckgo.com/?q=" + localurlEntrie.text
                    }
                    webView.url = searchTypeUrl
                }
                webpageUrlEntryDrawer.close()
            }

            onTextChanged: {
                webpageUrlEntryDrawer.evalAutoLogic();
            }

            Keys.onDownPressed: (event)=> {
                if(!inputPanel.active && suggestionsBox.visible){
                    suggestionsBox.forceActiveFocus()
                }
            }
        }

        SuggestionsBox {
            id: suggestionsBox
            model: completionItems
            width: parent.width
            anchors.top: localurlEntrie.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            filter: localurlEntrie.text
            property: "name"
            onItemSelected: complete(item)

            function complete(item) {
                if (item !== undefined) {
                    localurlEntrie.text = item.name
                }
            }
        }
    }
}
