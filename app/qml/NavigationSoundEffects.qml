/*
    SPDX-FileCopyrightText: 2022 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.12
import QtMultimedia 5.12
import Aura 1.0 as Aura

pragma Singleton

QtObject {
    id: navigationSoundEffects

    property SoundEffect clickedSound: SoundEffect {
        source: Qt.resolvedUrl("sounds/clicked.wav")
    }

    property SoundEffect movingSound: SoundEffect {
        source: Qt.resolvedUrl("sounds/clicked.wav")
    }

    function stopNavigationSounds() {
        if (clickedSound.playing) {
            clickedSound.stop();
        }
        if (movingSound.playing) {
            movingSound.stop();
        }
    }

    function playClickedSound() {
        if(Aura.GlobalSettings.soundEffects){
            clickedSound.play();
        }
    }

    function playMovingSound() {
        if(Aura.GlobalSettings.soundEffects){
            movingSound.play();
        }
    }
}
