class Say: Command {
    init() {
        super.init(syntax: ["say"], args: -1, exec: { msg, args, room in
            var sayMsg = ""
            for arg in args {
                if arg != "say" {
                    sayMsg += "\(arg) "
                }
            }
            room.postMessage(sayMsg)
        })
    }
}
