class MyPrivileges: Command {
    init() {
        super.init(syntax: ["myprivileges", "myprivs"], args: 1, exec: { msg, _, room in
            if Privil
            room.postMessage(":\(msg.id!) Finding for some socks to wear")
        })
        self.description = "to get your privileges"
    }
}
