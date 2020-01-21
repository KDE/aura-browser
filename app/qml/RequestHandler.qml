import QtQuick 2.10
import QtQuick.Controls 2.10
import QtWebEngine 1.8
import QtWebChannel 1.0
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.11 as Kirigami

Rectangle {
    property bool isRequested: false
    property alias source: interactionLoader.source
    property alias interactionItem: interactionLoader.item

    visible: isRequested
    enabled: isRequested
    width: parent.width
    height: isRequested ? Kirigami.Units.gridUnit * 4 : 0
    color: Kirigami.Theme.backgroundColor

    function setSource(interactionSource){
        interactionLoader.setSource(interactionSource)
    }

    Keys.onEscapePressed: {
        isRequested = false;
    }

    Keys.onBackPressed: {
        isRequested = false;
    }

    Loader {
       id: interactionLoader
       anchors.fill: parent
    }
}
