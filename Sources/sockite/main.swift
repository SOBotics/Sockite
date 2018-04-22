import Foundation
import SwiftChatSE
import SwiftRedunda
import Yams

let creds = try YAMLDecoder().decode(Creds.self, from: String(contentsOf: URL(fileURLWithPath: "creds.yml"), encoding: .utf8))

let commandService = CommandService()
let pingService = RedundaPingService(key: creds.redunda_key, version: "0.1.0")

let client = Client()
try! client.login(email: creds.email, password: creds.password)

var rooms: [ChatRoom] = []

for requiredRoom in creds.rooms {
    let room = ChatRoom(client: client, host: .stackOverflow, roomID: requiredRoom)
    try! room.join()
    rooms.append(room)
}

pingService.delegate = RedundaPingDelegate()
pingService.ping()
pingService.startPinging()

Thread.sleep(forTimeInterval: 20)
broadcastMessage("[ [Sockite](https://github.com/SOBotics/Sockite) ] started (running on \(pingService.getLocation()))")

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
