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
    property var requestedFeature;
    property url securityOrigin;

    width: parent.width
    height: parent.height

    onRequestedFeatureChanged: {
        message.text = securityOrigin + " has requested access to your "
                + message.textForFeature(requestedFeature);
    }

    RowLayout {
        anchors.fill: parent

        Label {
            id: message
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            color: Kirigami.Theme.textColor

            function textForFeature(feature) {
                if (feature === WebEngineView.MediaAudioCapture)
                    return "microphone"
                if (feature === WebEngineView.MediaVideoCapture)
                    return "camera"
                if (feature === WebEngineView.MediaAudioVideoCapture)
                    return "camera and microphone"
                if (feature === WebEngineView.Geolocation)
                    return "location"
            }
        }

        Button {
            id: acceptButton
            text: "Accept"
            palette.buttonText: Kirigami.Theme.textColor
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large

            background: Rectangle {
                color: acceptButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 20
            }

            onClicked: {
                webView.grantFeaturePermission(securityOrigin,
                                            requestedFeature, true);
                interactionBar.isRequested = false;
            }
        }

        Button {
            id: denyButton
            text: "Deny"
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large
            palette.buttonText: Kirigami.Theme.textColor

            background: Rectangle {
                color: denyButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
                border.color: Kirigami.Theme.disabledTextColor
                radius: 20
            }

            onClicked: {
                webView.grantFeaturePermission(securityOrigin,
                                            requestedFeature, false);
                interactionBar.isRequested = false
            }
        }

        Button {
            id: closeButton
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: Kirigami.Units.iconSizes.large - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing)
            Layout.preferredHeight: Kirigami.Units.iconSizes.large - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing)
            Layout.leftMargin: Kirigami.Units.largeSpacing
            palette.buttonText: Kirigami.Theme.textColor

            background: Rectangle {
                color: denyButton.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
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
