import Darwin

class Reboot: Command {
    init() {
        super.init(syntax: ["reboot"], args: 1, exec: { msg, _, room in
            room.postMessage("Rebooting...")
            sleep(UInt32(5))
            Log.logWarning("Bot rebooting, ordered by command in room \(room.roomID) by \(msg.user.name)")
            exit(5)
        })
        self.description = "reboot"
        self.requiredPrivileges = .admin
    }
}
