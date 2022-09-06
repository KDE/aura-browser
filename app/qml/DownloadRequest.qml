/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.7
import QtWebChannel 1.0
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami

Item {
    property var download
    property var messageText
    property bool actionsVisible: true
    property bool isDownloading: false
    property var downloadBytes: download.receivedBytes
    property string downloadName

    onDownloadBytesChanged: {
        downloadProgressBar.value = downloadBytes / download.totalBytes
    }

    width: parent.width
    height: parent.height

    onMessageTextChanged: {
        message.text = messageText
    }

    RowLayout {
        anchors.fill: parent

        Label {
            id: message
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            text: i18n("Do you want to download %1 file ?", downloadName)
            color: Kirigami.Theme.textColor
        }

        Button {
            id: downloadButton
            text: "Download"
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            visible: actionsVisible && !isDownloading
            palette.buttonText: Kirigami.Theme.textColor

            background: Rectangle {
                color: downloadButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 20
            }

            onClicked: {
                download.resume();
                message.text = i18n("Downloading.. %1", downloadName)
                isDownloading = true;
                if(download.totalBytes != -1){
                    downloadProgressBar.indeterminate = false
                } else {
                    downloadProgressBar.indeterminate = true
                }
            }
        }

        ProgressBar {
            id: downloadProgressBar
            visible: isDownloading
            enabled: isDownloading
            Layout.preferredWidth: Kirigami.Units.iconSizes.large * 2
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.alignment: Qt.AlignRight
            from: 0
            to: 1
        }

        Button {
            id: cancleButton
            text: i18n("Cancel")
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            visible: actionsVisible
            palette.buttonText: Kirigami.Theme.textColor

            background: Rectangle {
                color: cancleButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 20
            }

            onClicked: {
                download.cancel()
                interactionBar.isRequested = false
            }
        }

        Button {
            id: closeButton
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing)
            Layout.preferredHeight: Kirigami.Units.iconSizes.large - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing)
            Layout.leftMargin: Kirigami.Units.largeSpacing

            background: Rectangle {
                color: closeButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 200
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.medium
                height: Kirigami.Units.iconSizes.medium
                source: "window-close"
            }

            onClicked: {
                interactionBar.isRequested = false
            }
        }
    }
}
