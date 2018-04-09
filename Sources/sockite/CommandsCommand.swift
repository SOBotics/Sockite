class Commands: Command {
    init () {
        super.init(syntax: ["commands"], args: 1, exec: { msg, _, room in
            var cmdMsg = ""
            for cmd in commands {
                var cmdName = ""
                for syntax in cmd.syntax {
                    cmdName.append(syntax)
                    if syntax != cmd.syntax.last {
                        cmdName.append(",")
                    }
                }
                let desc = cmd.description ?? "No description found"
                cmdMsg.append("\(cmdName): \(desc)\n")
            }
            room.postMessage(":\(msg.id!) Here are my commands:\n \(cmdMsg)")
        })
    }
}
