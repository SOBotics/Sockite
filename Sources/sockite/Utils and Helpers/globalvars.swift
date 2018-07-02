import Darwin

// array of commands
let commands: [Command] = [Alive(), Checkusers(), Say(), Help(), Commands(), Checkuser(), Delete(), Quota()]

let sockitePrefix = "[ [Sockite](https://github.com/SOBotics/Sockite) ]"

var quota = 10000 {
    didSet {
        Log.logInfo("Quota of \(quota) left")
        if quota == 1 {
            Log.handle(error: "No quota left, shutting down", consoleOutputPrefix: nil, postToChat: false)
            broadcastMessage("!!! No quota left !!!\nBot will be shutting down, please contact @paper1111 if you have issues.")
            exit(69)
        }
    }
}

var backoff = false

var version = "<undefined>"
var location = "<undefined>"

var dataDir = "<undefined>" {
    didSet {
        if dataDir.last! != "/" {
            dataDir.append("/")
        }
        Log.logInfo("updated data directory to \(dataDir)")
    }
}
