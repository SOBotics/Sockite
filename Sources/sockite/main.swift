import Foundation
import SwiftChatSE
import SwiftRedunda

if CommandLine.arguments.contains("--reboot") {
    Log.log("Rebooted from command", withColor: .lightMagenta)
} else if CommandLine.arguments.contains("--err") {
    Log.log("Recovering from error", withColor: .lightMagenta)
} else {
    Log.log("Welcome to Sockite! Now starting up!", withColor: .lightMagenta)
}
Log.logInfo("Decoding credentials...")
let creds = try! JSONDecoder().decode(Creds.self, from: Data(contentsOf: URL(fileURLWithPath: "creds.json")))

Log.logInfo("Initializing globalvars...")
dataDir = creds.data_dir
if CommandLine.arguments.contains("--rev") {
    rev = CommandLine.arguments[CommandLine.arguments.index(of: "--rev")! + 1]
}

Log.logInfo("Initializing logfile...")
try? FileManager.default.removeItem(atPath: dataDir + "logfile.log") // reset logfile
FileManager.default.createFile(atPath: dataDir + "logfile.log", contents: nil)

Log.logInfo("Initializing commands...")
let commandService = CommandService()

Log.logInfo("Starting chat service...")
let client = Client()
do {
     try client.login(email: creds.email, password: creds.password)
} catch Client.LoginError.loginFailed {
    Log.handle(error: "Cannot log in to chat service, maybe the login credentials were wrong or we were presented with a CAPTCHA")
    exit(0)
} catch {
    exit(1)
}

var rooms: [ChatRoom] = []

for requiredRoom in creds.rooms {
    let room = ChatRoom(client: client, host: .stackOverflow, roomID: requiredRoom)
    try! room.join()
    rooms.append(room)
}

Log.logInfo("Initializing Redunda...")
let pingService = RedundaPingService(key: creds.redunda_key, version: rev)
if CommandLine.arguments.contains("--dev") {
    Log.log("[INFO] Launching in development mode, Redunda should not be pinged", withColor: .green)
    pingService.debug = true
}
pingService.delegate = RedundaPingDelegate()
pingService.startPinging()

Log.logInfo("Initializing network connections...")
Thread.sleep(forTimeInterval: 3)
Log.logInfo("Connecting database...")
let sqliteHelper = SQLiteHelper()
sqliteHelper.connect()
sqliteHelper.give(user: "7347933", privilege: .admin)
location = pingService.getLocation()
Log.logInfo("Sockite started!")
if CommandLine.arguments.contains("--reboot") {
    broadcastMessage("\(sockitePrefix) rebooted (running on \(location))")
} else if CommandLine.arguments.contains("--err") {
    broadcastMessage("\(sockitePrefix) recovered from error (running on \(location))")
} else if pingService.shouldStandby() {
    broadcastMessage("\(sockitePrefix) started in standby mode (running on \(location))", force: true)
} else {
    broadcastMessage("\(sockitePrefix) started (running on \(location))")
}
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
