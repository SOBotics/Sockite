import Foundation
import Rainbow

struct Log {
    static func log(_ str: String, withColor color: Color = .`default`, withDate date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSSS"
        if color == .`default` {
            print("[\(formatter.string(from: date))] \(str)")
        } else {
            print("[\(formatter.string(from: date))] \(str.applyingColor(color))")
        }
        if dataDir != "<undefined>" {
            let url = URL(fileURLWithPath: dataDir + "logfile.log")
            do {
                let newStr = "\(str.clearColor)\n"
                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                fileHandle.write(newStr.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("!Warning! Error in writing items to log: \(error.localizedDescription) (This can be safely ignored if it occurs a few seconds after startup)")
            }
        }
    }
    
    static func handle(error: String, consoleOutputPrefix: String? = nil, postToChat: Bool = true) {
        if let prefix = consoleOutputPrefix {
            Log.log("[ERROR][\(prefix)] \(error)".lightRed)
        } else {
            Log.log("[ERROR] \(error)".lightRed)
        }
        if postToChat {
            broadcastMessage(error)
        }
    }
    
    static func logWarning(_ str: String, consoleOutputPrefix: String? = nil) {
        if let prefix = consoleOutputPrefix {
            Log.log("[WARN][\(prefix)] \(str)".lightYellow)
        } else {
            Log.log("[WARN] \(str)".lightYellow)
        }
    }
    
    static func logInfo(_ str: String, consoleOutputPrefix: String? = nil) {
        if let prefix = consoleOutputPrefix {
            Log.log("[INFO][\(prefix)] \(str)")
        } else {
            Log.log("[INFO] \(str)")
        }
    }
}
