class Quota: Command {
    init() {
        super.init(syntax: ["quota", "apiquota"], args: 1, exec: { msg, _, room in
            room.postMessage(":\(msg.id!) Quota left: \(quota)")
        })
        self.description = "prints a help message"
    }
}
