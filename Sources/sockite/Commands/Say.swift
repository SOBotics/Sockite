class Say: Command {
    init() {
        super.init(syntax: ["say"], args: -1, exec: { msg, args, room in
            var variableArgs: [String] = args
            variableArgs.remove(at: 0)
            room.postMessage(variableArgs.joined(separator: " "))
        })
        self.description = "repeat the argument provided"
    }
}
