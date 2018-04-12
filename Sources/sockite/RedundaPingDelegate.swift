import SwiftRedunda
import Foundation
import Rainbow

class RedundaPingDelegate: RedundaPingServiceDelegate {
    func handle(error: Error) {
        broadcastMessage("Error occured when pinging Redunda: \(error) (@paper)")
    }
    func statusChanged(newStatus: Bool) {
        Log.log("[Redunda] new status happened! status: \(newStatus)".yellow)
    }
    func pinged(response: RedundaPingResponse) {
        Log.log("[Redunda] pinged Redunda".yellow, withDate: Date())
    }
}
