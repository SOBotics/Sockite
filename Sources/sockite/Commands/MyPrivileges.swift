class MyPrivileges: Command {
    init() {
        super.init(syntax: ["myprivileges", "myprivs"], args: 1, exec: { msg, _, room in
            let priv = PrivilegeManager.checkPrivilegeLevel(ofChatUser: msg.user)
            if priv == .nothing {
                room.postMessage(":\(msg.id!) You don't have any privileges.")
            } else {
                room.postMessage(":\(msg.id!) You have the privilege \(priv).")
            }
        })
        self.description = "to get your privileges"
    }
}
