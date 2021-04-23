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
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import QtQuick.LocalStorage 2.12
import org.kde.kirigami 2.11 as Kirigami
import "code/RecentStorage.js" as RecentStorage
import "code/Utils.js" as Utils
import Aura 1.0 as Aura
import QtQuick.VirtualKeyboard 2.4

Kirigami.OverlayDrawer {
    id: webpageUrlEntryDrawer
    width: parent.width
    height: parent.height
    edge: Qt.TopEdge
    dragMargin: 0
    dim: true

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

    Item {
        id: entryLayout
        anchors.fill: parent

        RowLayout {
            id: localHeaderAreaURLandSearchField
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Kirigami.Heading {
                id: localUrlSearchFieldLabel
                level: 1
                text: "Enter URL / Search Term"
                width: parent.width
                horizontalAlignment: Qt.AlignLeft
                Layout.alignment: Qt.AlignLeft
            }

            Label {
                id: localUrlSearchFieldBackBtnLabel
                text: "Press 'esc' or the [←] Back button to close"
                Layout.alignment: Qt.AlignRight
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
            placeholderText: "Enter Search Term or URL"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            background: Rectangle {
                color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1
            }

            onAccepted: {
                var evaluateExist = webpageUrlEntryDrawer.autoAppend(completionItems, function(item) { return item.name === localurlEntrie.text }, localurlEntrie.text)
                console.log(evaluateExist)
                if(evaluateExist === null){
                    console.log("Appending Item to AutoComp")
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

            Keys.onDownPressed: {
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
