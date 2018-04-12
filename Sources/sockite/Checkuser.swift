class Checkuser: Command {
    init() {
        super.init(syntax: ["checkuser"], args: 2, exec: { msg, args, room in
            FilterSocks.getScoreOfUserAndTarget(user: args[1], { res, err in
                if let error = err {
                    room.postMessage("An error occured while executing this command: \(error))")
                } else if let res = res {
                    room.postMessage(":\(msg.id!) Here are the possible socks:")
                    for (user, (score, reasons)) in res {
                        room.postMessage("User [\(user)](https://stackoverflow.com/u/\(user)): **\(reasons)**; **\(score)**")
                    }
                } else {
                    room.postMessage(":\(msg.id!) This user does not seem to have any socks.")
                }
            })
        })
    }
}
