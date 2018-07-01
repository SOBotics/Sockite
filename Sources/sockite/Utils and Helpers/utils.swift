import SwiftChatSE

func broadcastMessage(_ msg: String) {
    for room in rooms {
        room.postMessage(msg)
    }
}

func checkForChooChoo(inMessage msg: ChatMessage) {
    if msg.content == "🚂" && msg.user.id == 7481043 && msg.room.roomID == 111347 {
        msg.room.postMessage("[🚃](https://youtu.be/bQGj3F5KTB8?t=13s)")
    }
}
