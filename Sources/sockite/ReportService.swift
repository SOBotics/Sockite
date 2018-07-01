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
    
    func determineAndScan(users: [Owner]) {
        
    }
    
    func scan(userId: String) {
        
    }
}
