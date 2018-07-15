class Commands: Command {
    init() {
        super.init(syntax: ["commands"], args: 1, exec: { msg, _, room in
            var cmdMsg = ""
            for cmd in commands {
                let cmdName = cmd.syntax.joined(separator: ", ")
                let desc = cmd.description ?? "No description found"
                cmdMsg.append("    \(cmdName.padding(toLength: 30, withPad: " ", startingAt: 0)) \(desc)\n")
            }
            room.postMessage(":\(msg.id!) Here are my commands:")
            room.postMessage(cmdMsg)
        })
        
        self.description = "returns a list of commands"
    }
}
