import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.11 as Kirigami
import QtGraphicalEffects 1.0
import Aura 1.0 as Aura

Controls.Control {
    id: inptLoader
    property Item rootTarget

    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    background: Rectangle {
        color: inptLoader.activeFocus ? Kirigami.Theme.highlightColor : Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)
        border.color: Kirigami.Theme.disabledTextColor
        radius: 20
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: Qt.rgba(0,0,0,0.6)
        }
    }

    contentItem: Item {
        Kirigami.Icon {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: "audio-input-microphone"
        }

        AudioBox {
            id: audRecBox
            parent: rootTarget
            width: rootTarget.width / 2
            height: rootTarget.height / 2
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            onClosed: {
                mInputLoader.item.sendRequest();
            }
        }

        Loader {
            id: mInputLoader
            source: "MycroftInput.qml"
        }
    }

    Keys.onReturnPressed: {
        audRecBox.open()
        Aura.AudioRecorder.start()
        delay(8000, function() {
            audRecBox.close()
        });
    }

    MouseArea {
        id: inputLoaderMArea
        anchors.fill: parent
        onClicked: {
            audRecBox.open()
            Aura.AudioRecorder.start()
            delay(10000, function() {
                audRecBox.close()
            });
        }
    }
}
