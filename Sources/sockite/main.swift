import Foundation
import SwiftChatSE
import SwiftRedunda
import Yams

Log.log("Welcome to Sockite! Now starting up!", withColor: .lightMagenta)
Log.logInfo("Decoding credentials...")
let creds = try YAMLDecoder().decode(Creds.self, from: String(contentsOf: URL(fileURLWithPath: "creds.yml"), encoding: .utf8))

Log.logInfo("Initializing globalvars...")
dataDir = creds.data_dir

Log.logInfo("Initializing logfile...")
try? FileManager.default.removeItem(atPath: dataDir + "logfile.log") // reset logfile
FileManager.default.createFile(atPath: dataDir + "logfile.log", contents: nil)

Log.logInfo("Initializing commands...")
let commandService = CommandService()

Log.logInfo("Starting chat service...")
let client = Client()
try! client.login(email: creds.email, password: creds.password)

var rooms: [ChatRoom] = []

for requiredRoom in creds.rooms {
    let room = ChatRoom(client: client, host: .stackOverflow, roomID: requiredRoom)
    try! room.join()
    rooms.append(room)
}

Log.logInfo("Initializing Redunda...")
let pingService = RedundaPingService(key: creds.redunda_key, version: "0.1.0")
pingService.delegate = RedundaPingDelegate()
pingService.ping()
pingService.startPinging()

Log.logInfo("Initializing network connections...")
Thread.sleep(forTimeInterval: 10)
Log.logInfo("Connecting database...")
let sqliteHelper = SQLiteHelper()
sqliteHelper.connect()
location = pingService.getLocation()
Log.logInfo("Sockite started!")
broadcastMessage("\(sockitePrefix) started (running on \(location))")
Log.logInfo("Starting sock reporting service...")
let reportService = ReportService()
reportService.startScanning()

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
