/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
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
import QtQuick.Layouts 1.3
import QtQuick.Window 2.10
import QtQuick.Controls 2.10 as Controls
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.11 as Kirigami
import Aura 1.0 as Aura

GridView {
    id: view
    focus: true
    signal activated
    property string title
    property alias delegate: view.delegate
    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem
    property int columns: Math.max(3, Math.floor(width / (Kirigami.Units.gridUnit * 15)))

    width: parent.width
    height: parent.height

    z: activeFocus ? 10 : 1
    keyNavigationEnabled: true
    highlightFollowsCurrentItem: true
    cacheBuffer: width
    cellWidth: Math.floor(width / columns)
    cellHeight: view.height / 2
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

    Keys.onPressed: {
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
}
