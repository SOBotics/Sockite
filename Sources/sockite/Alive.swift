class Alive: Command {
    init() {
        super.init(syntax: ["alive"], args: 1, exec: { msg, _, room in
            room.postMessage(":\(msg.id!) Yup")
        })
    }
}
