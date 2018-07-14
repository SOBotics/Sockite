import SwiftChatSE

class Delete: Command {
    init() {
        super.init(syntax: ["delete", "del", "poof", "remove"], args: 1, exec: { msg, args, room in
            do {
                Log.logInfo("Delete executing")
                try msg.room.delete(msg.replyID!)
            } catch {
                room.postMessage("This message can't be deleted!")
            }
        })
        
        self.reply = true
        self.description = "deletes the given message by Sockite"
        self.requiredPrivileges = .admin
    }
}
