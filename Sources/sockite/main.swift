import Foundation
import SwiftChatSE
import SwiftRedunda
import Yams

let creds = try YAMLDecoder().decode(Creds.self, from: String(contentsOf: URL(fileURLWithPath: "creds.yml"), encoding: .utf8))

let commandService = CommandService()
let pingService = RedundaPingService(key: creds.redunda_key, version: "0.1.0")

let client = Client()
try! client.login(email: creds.email, password: creds.password)

let sobotics = ChatRoom(client: client, host: .stackOverflow, roomID: 111347)
try! sobotics.join()

let rooms = [sobotics]
broadcastMessage("[ [Sockite](https://github.com/SOBotics/Sockite) ] started in test mode (running on paper1111/iMac)")
pingService.delegate = RedundaPingDelegate()
pingService.ping()
pingService.startPinging()

for room in rooms {
    room.onMessage { msg, edit in
        if !pingService.shouldStandby() {
            commandService.recieveMsg(msg, edit, room)
        }
    }
}

while true {
    // don't die
}
