import SwiftChatSE

func broadcastMessage(_ msg: String) {
    for room in rooms {
        room.postMessage(msg)
    }
}

func checkForSpecialReplies(inMessage msg: ChatMessage) {
    if msg.content == "🚂" && msg.user.id == 7481043 {
        msg.room.postMessage("[🚃](https://youtu.be/bQGj3F5KTB8?t=13s)")
    } else if msg.content == "@bots alive" {
        msg.room.postMessage("Finding for some socks to wear")
    }
}
