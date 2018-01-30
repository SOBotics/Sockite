class Say: Command {
    init() {
        super.init(syntax: ["say"], args: 2, exec: { msg, args, room in
            room.postMessage(args[1])
        })
    }
}
