import SwiftChatSE
import SwiftRedunda

let commandService = CommandService()
let pingService = RedundaPingService(key: "", version: "0.1.0")

let email = ""
let password = ""

let client = Client()
try! client.login(email: email, password: password)

let room = ChatRoom(client: client, host: .stackOverflow, roomID: 111347)
try! room.join()

room.postMessage("[ 玄 | Sockite ] started in test mode (running on paper1111/iMac)")
pingService.startPinging()

room.onMessage { msg, edit in
    if !pingService.shouldStandby() {
        commandService.recieveMsg(msg, edit)
    }
}

while true {
    // don't die
}
