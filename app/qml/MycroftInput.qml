import QtQuick 2.12
import QtWebSockets 1.1
import Aura 1.0 as Aura

Item {
    id: mycroftInputRoot
    signal sendRequest

    onSendRequest: {
        console.log("Sending request to mycroft")
        sendMsg();
    }

    WebSocket {
        id: socket
        url: "ws://127.0.0.1:8181/core"
        onTextMessageReceived: {
            var somemessage = JSON.parse(message)
            if (somemessage.type == "aura.browser.request.result"){
                var result = somemessage.data.result
                Aura.NavigationSoundEffects.playClickedSound();
                var searchTypeUrl
                if(Aura.GlobalSettings.defaultSearchEngine == "Google"){
                    searchTypeUrl = "https://www.google.com/search?q=" + result
                } else if (Aura.GlobalSettings.defaultSearchEngine == "DDG") {
                    searchTypeUrl = "https://duckduckgo.com/?q=" + result
                }
                createTab(searchTypeUrl)
            }
        }

        onActiveChanged: {
            if(active){
                console.log("Connected To Mycroft")
            }
        }
    }

    function sendMsg() {
        var socketmessage = {};
        socketmessage.type = "aura.browser.request.stt";
        socketmessage.data = {};
        socketmessage.data.file = "/tmp/aura_in.raw";
        socket.sendTextMessage(JSON.stringify(socketmessage));
    }

    Component.onCompleted: {
        socket.active = true
    }
}
