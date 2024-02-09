/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as Controls
import Aura 1.0 as Aura
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Controls.Popup {
    id: urlEntryDrawer
    width: parent.width * 0.8
    height: parent.height * 0.8
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: false
    dim: true
    padding: Kirigami.Units.largeSpacing
    z: 2

    function checkURL(value) {
        var urlregex = new RegExp("^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$");
        if (urlregex.test(value)) {
            return (true);
        }
        return (false);
    }

    onOpened: {
        urlEntrie.forceActiveFocus()
    }

    Controls.Overlay.modeless: Rectangle {
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