class Alive: Command {
    init() {
        super.init(syntax: ["alive"], args: 1, exec: { msg, _, room in
            room.postMessage(":\(msg.id!) Finding for some socks to wear")
        })
        self.description = "to check the status of the bot"
    }
}
