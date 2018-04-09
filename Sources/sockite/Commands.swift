import SwiftChatSE

class Command {
    
    var syntax: [String]
    var args: Int
    var handler: (ChatMessage, [String], ChatRoom) -> ()
    var description: String?
    
    init(syntax: [String], args: Int, exec: @escaping (ChatMessage, [String], ChatRoom) -> ()) {
        self.syntax = syntax
        self.args = args
        self.handler = exec
    }
}

class CommandService {
    func recieveMsg(_ msg: ChatMessage, _ isEdit: Bool, _ room: ChatRoom) {
        var msgContent: String = msg.content
        if !msgContent.lowercased().starts(with: "@sock") {
            return
        }
        guard let spaceRange = msgContent.range(of: " ") else {
            return
        }
        msgContent.removeSubrange(msgContent.startIndex..<spaceRange.upperBound)
        print(msgContent)
        let msgParts = msgContent.components(separatedBy: " ")
        for command in commands {
            if command.args == msgParts.count || command.args == -1 {
                for syntax in command.syntax {
                    if syntax == msgParts[0] {
                        print("cmd works")
                        if msg.user.id == 8449076 {
                            room.postMessage("Don't try to break me...")
                        }
                        command.handler(msg, msgParts, room)
                    }
                }
            }
        }
    }
}
