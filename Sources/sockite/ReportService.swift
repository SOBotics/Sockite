import Dispatch
import Foundation

class ReportService {
    
    private var scanning = false
    private let userScanQueue = UserScanQueue()
    
    func startScanning(withTimeInterval timeInterval: Int = 1200) {
        scanning = true
        let queue = DispatchQueue(label: "sockite_report_service", attributes: .concurrent)
        queue.async {
            while self.scanning {
                SEAPIHelper.getBadges { badgeReciepents in
                    Log.logInfo("Batching users for scan...", consoleOutputPrefix: "ReportService")
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
            if !sqliteHelper.searchIfUserChecked(user) {
                Log.logInfo("User \(user.user_id!) is on the queue to be scanned", consoleOutputPrefix: "ReportService")
                self.userScanQueue.queue.push(value: user)
            }
        }
        self.userScanQueue.flushQueue()
    }
}
