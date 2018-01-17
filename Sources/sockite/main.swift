import SwiftChatSE

let commandService = CommandService()

let email = "hilarylau12342@gmail.com"
let password = "p4e3a2d1b"

let client = Client()
try! client.login(email: email, password: password)

let room = ChatRoom(client: client, host: .stackOverflow, roomID: 111347)
try! room.join()

room.postMessage("[ 玄 | Sockite ] started in test mode (running on paper1111/iMac)")

room.onMessage { msg, edit in
    print(msg.content)
    commandService.recieveMsg(msg, edit)
}

while true {
    // don't die
}
