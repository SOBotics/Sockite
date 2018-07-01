import Foundation
import Rainbow

struct Log {
    static func log(_ str: String, withColor color: Color = .`default`, withDate date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/mm/dd HH:mm:ss:SSSS"
        print("[\(formatter.string(from: date))] \(str)")
    }
    
    static func handle(error: String, consoleOutputPrefix: String? = nil) {
        if let prefix = consoleOutputPrefix {
            Log.log("[ERROR][\(prefix)] \(error)".lightRed)
            broadcastMessage(error)
        } else {
            Log.log("[ERROR] \(error)".lightRed)
            broadcastMessage(error)
        }
    }
    
    static func logWarning(_ str: String, consoleOutputPrefix: String? = nil) {
        
    }
    
    static func logInfo(_ str: String, consoleOutputPrefix: String? = nil) {
        if let prefix = consoleOutputPrefix {
            Log.log("[INFO][\(prefix)] \(str)")
        } else {
            Log.log("[INFO] \(str)")
        }
    }
    
    static func logReportService() {
        // stub
    }
}
