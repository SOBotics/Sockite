import Darwin

// array of commands
let commands: [Command] = [Alive(), Checkusers(), Say(), Help(), Commands(), Checkuser(), Delete(), Quota()]

let sockitePrefix = "[ [Sockite](https://github.com/SOBotics/Sockite) ]"

var quota = 10000 {
    didSet {
        if quota == 1 {
            Log.handle(error: "No quota left, shutting down", consoleOutputPrefix: nil, postToChat: false)
            broadcastMessage("!!! No quota left !!!\nBot will be shutting down, please contact @paper1111 if you have issues.")
            exit(69)
        }
    }
}
