class Help: Command {
    init() {
        super.init(syntax: ["help"], args: 1, exec: { msg, _, room in
            room.postMessage(":\(msg.id!) I'm a bot that tries to catch sock puppets!")
        })
        self.description = "prints a help message"
    }
}
