import Darwin

class Kill: Command {
    init() {
        super.init(syntax: ["kill", "die", "quit"], args: 1, exec: { msg, _, room in
            room.postMessage("Tearing apart...")
            sleep(UInt32(5))
            Log.logWarning("Bot stopping, ordered by command in room \(room.roomID) by \(msg.user.name)")
            exit(0)
        })
        self.description = "kills the bot"
        self.requiredPrivileges = .admin
    }
}
