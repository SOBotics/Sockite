import Dispatch

class ReportService {
    
    private var scanning = false
    
    func startScanning(withTimeInterval timeInterval: Int = 600) {
        scanning = true
        let queue = DispatchQueue(label: "sockite_report_service", attributes: .concurrent)
        queue.async {
            while self.scanning {
                SEAPIHelper.getBadges { badgeReciepents in
                    self.determineAndScan(users: badgeReciepents.items!.map { $0.user! })
                }
                sleep(UInt32(timeInterval))
            }
        }
    }
    
    func stopScanning() {
        if !scanning {
            Log.handle(error: "Scanning stopped already!")
        }
        scanning = false
    }
    
    func isScanning() -> Bool {
        return scanning
    }
    
    func determineAndScan(users: [User]) {
        for user in users {
            let strUserId = String(user.user_id!)
            if !sqliteHelper.searchIfUserChecked(user) {
                Log.logInfo("User \(strUserId) is on the queue to be scanned", consoleOutputPrefix: "ReportService")
                FilterSocks.getScoreOfUserAndTarget(user: strUserId, { res, err in
                    if let error = err {
                        Log.handle(error: "An error occurred while scanning user \(strUserId): \(error.localizedDescription)", consoleOutputPrefix: "ReportService")
                    } else if let res = res {
                        Log.logInfo("Possible socks of user \(strUserId) found!", consoleOutputPrefix: "ReportService")
                        broadcastMessage("\(sockitePrefix) Possible socks of user [\(strUserId)](https://stackoverflow.com/u/\(strUserId))")
                        for (user, (score, reasons)) in res {
                            broadcastMessage("User [\(user)](https://stackoverflow.com/u/\(user)): **\(reasons)**; **\(score)**")
                        }
                    } else {
                        Log.logInfo("User \(strUserId) scanned, no socks found", consoleOutputPrefix: "ReportService")
                    }
                })
            }
        }
    }
}
