class UserScanQueue {
    
    var queue: Queue<User> = []
    var scanning = false
    
    func flushQueue() {
        Log.logInfo("Flushing queue...", consoleOutputPrefix: "UserScanQueue")
        while !queue.isEmpty {
            let poppedUser = queue.pop()
            self.scanning = true
            Log.logInfo("Scanning user \(poppedUser.user_id!)...", consoleOutputPrefix: "UserScanQueue")
            self.scan(String(poppedUser.user_id!))
            while scanning {
                //wait until scanning finished
            }
        }
        Log.logInfo("Queue flushed", consoleOutputPrefix: "UserScanQueue")
    }
    
    func scan(_ strUserId: String) {
        FilterSocks.getScoreOfUserAndTarget(user: strUserId, { res, err in
            Log.logInfo("Response from FilterSocks received", consoleOutputPrefix: "ReportService|UserScanQueue")
            if let error = err {
                Log.handle(error: "An error occurred while scanning user \(strUserId): \(error.localizedDescription)", consoleOutputPrefix: "ReportService|UserScanQueue")
            } else if let res = res {
                Log.logInfo("Possible socks of user \(strUserId) found!", consoleOutputPrefix: "ReportService|UserScanQueue")
                broadcastMessage("\(sockitePrefix) Possible socks of user [\(strUserId)](https://stackoverflow.com/u/\(strUserId))")
                for (user, (score, reasons)) in res {
                    broadcastMessage("User [\(user)](https://stackoverflow.com/u/\(user)): **\(reasons)**; **\(score)**")
                }
            } else {
                Log.logInfo("User \(strUserId) scanned, no socks found", consoleOutputPrefix: "ReportService|UserScanQueue")
            }
            sqliteHelper.insertChecked(userId: strUserId)
            self.scanning = false
        })
    }
}
