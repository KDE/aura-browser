/*
    SPDX-FileCopyrightText: 2019 Aditya Mehra <aix.m@outlook.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Window 2.10
import QtQuick.Controls 2.10 as Controls
import Aura 1.0 as Aura
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

FocusScope {
    id: root
    signal activated
    property string title
    property alias view: view
    property alias delegate: view.delegate
    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem

    implicitHeight: view.implicitHeight + header.implicitHeight

    //TODO:dynamic
    property int columns: Math.max(3, Math.floor(width / (Kirigami.Units.gridUnit * 15)))

    property alias cellWidth: view.cellWidth
    readonly property real screenRatio: view.Window.window ? view.Window.window.width / view.Window.window.height : 1.6

    property Item navigationUp
    property Item navigationDown

    Kirigami.Heading {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        text: title
        color: Kirigami.Theme.textColor
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: Qt.rgba(0,0,0,0.6)
        }
    }
    
    ListView {
        id: view
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
        }
        focus: true

        z: activeFocus ? 10: 1
        keyNavigationEnabled: true
        //Centering disabled as experiment
        //highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: true
        snapMode: ListView.SnapToItem
        cacheBuffer: width
        implicitHeight: Math.floor(cellWidth/screenRatio)

        highlight: Rectangle {
            color: Kirigami.Theme.linkColor
        }

        readonly property int cellWidth: Math.floor(width / columns)
        //preferredHighlightBegin: width/view.columns
        //preferredHighlightEnd: width/view.columns * 2

        displayMarginBeginning: rotation.angle != 0 ? width*2 : 0
        displayMarginEnd: rotation.angle != 0 ? width*2 : 0
        highlightMoveDuration: Kirigami.Units.longDuration
        transform: Rotation {
            id: rotation
            axis { x: 0; y: 1; z: 0 }
            angle: 0
            property real targetAngle: 30
            Behavior on angle {
                SmoothedAnimation {
                    duration: Kirigami.Units.longDuration * 10
                }
            }
            origin.x: width/2
        }

        Timer {
            id: rotateTimeOut
            interval: 25
        }
        Timer {
            id: rotateTimer
            interval: 500
            onTriggered: {
                if (rotateTimeOut.running) {
                    rotation.angle = rotation.targetAngle;
                    restart();
                } else {
                    rotation.angle = 0;
                }
            }
        }
        spacing: 0
        orientation: ListView.Horizontal

        opacity: Kirigami.ScenePosition.y >= 0
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }

        property real oldContentX
        onContentXChanged: {
            if (oldContentX < contentX) {
                rotation.targetAngle = 30;
            } else {
                rotation.targetAngle = -30;
            }
            Controls.ScrollBar.horizontal.opacity = 1;
            if (!rotateTimeOut.running) {
                rotateTimer.restart();
            }
            rotateTimeOut.restart();
            oldContentX = contentX;
        }
        Controls.ScrollBar.horizontal: Controls.ScrollBar {
            id: scrollBar
            opacity: 0
            interactive: false
            onOpacityChanged: disappearTimer.restart()
            Timer {
                id: disappearTimer
                interval: 1000
                onTriggered: scrollBar.opacity = 0;
            }
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        move: Transition {
            SmoothedAnimation {
                property: "x"
                duration: Kirigami.Units.longDuration
            }
        }

        KeyNavigation.left: root
        KeyNavigation.right: root

        Keys.onDownPressed: (event)=> {
            Aura.NavigationSoundEffects.playMovingSound();
            if (!navigationDown) {
                return;
            }

            if (navigationDown instanceof TileView) {
                navigationDown.currentIndex = navigationDown.view.indexAt(navigationDown.view.mapFromItem(currentItem, cellWidth/2, height/2).x, height/2);
                if (navigationDown.currentIndex < 0) {
                    navigationDown.currentIndex = view.currentIndex > 0 ? navigationDown.view.count - 1 : 0
                }
            }

            navigationDown.forceActiveFocus();
        }

        Keys.onUpPressed: (event)=> {
            Aura.NavigationSoundEffects.playMovingSound();
            if (!navigationUp) {
                return;
            }

            if (navigationUp instanceof TileView) {
                navigationUp.view.currentIndex = navigationUp.view.indexAt(navigationUp.view.contentItem.mapFromItem(currentItem, cellWidth/2, height/2).x, height/2);
                if (navigationUp.currentIndex < 0) {
                    navigationUp.currentIndex = view.currentIndex > 0 ? navigationUp.view.count - 1 : 0
                }
            }

            navigationUp.forceActiveFocus();
        }

        Keys.onPressed: (event)=> {
            switch (event.key) {
                case Qt.Key_Right:
                case Qt.Key_Left:
                case Qt.Key_Tab:
                case Qt.Key_Backtab:
                    Aura.NavigationSoundEffects.playMovingSound();
                    break;
                default:
                    break;
            }
        }
    }
}
