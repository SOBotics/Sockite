import SwiftChatSE

class Command {
    
    var syntax: [String]
    var args: Int
    var handler: (ChatMessage, [String], ChatRoom) -> ()
    var description: String?
    var reply = false
    var requiredPrivileges: Privileges = .nothing
    
    init(syntax: [String], args: Int, exec: @escaping (ChatMessage, [String], ChatRoom) -> ()) {
        self.syntax = syntax
        self.args = args
        self.handler = exec
    }
}

class CommandService {
    func recieveMsg(_ msg: ChatMessage, _ isEdit: Bool, _ room: ChatRoom) {
        checkForSpecialReplies(inMessage: msg)
        var msgContent: String = msg.content
        if !msgContent.lowercased().starts(with: "@sock") {
            return
        }
        guard let spaceRange = msgContent.range(of: " ") else {
            return
        }
        msgContent.removeSubrange(msgContent.startIndex..<spaceRange.upperBound)
        Log.logInfo("received message: \(msgContent)", consoleOutputPrefix: "CmdService")
        let msgParts = msgContent.components(separatedBy: " ")
        for command in commands {
            if command.args == msgParts.count || command.args == -1 {
                for syntax in command.syntax {
                    if syntax == msgParts[0] {
                        Log.logInfo("cmd works", consoleOutputPrefix: "CmdService")
                        if msg.user.id == 8449076 {
                            room.postMessage("Don't try to break me...")
                            return
                        }
                        if !PrivilegeManager.assertPrivilegeLevel(ofChatUser: msg.user, isHigherThan: command.requiredPrivileges) {
                            room.postMessage(":\(msg.id!) You don't have enough privileges!")
                        }
                        command.handler(msg, msgParts, room)
                        return
                    }
                }
            }
        }
    }
}
