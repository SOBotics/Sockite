import SwiftRedunda

class RedundaPingDelegate: RedundaPingServiceDelegate {
    func handle(error: Error) {
        broadcastMessage("Error occured when pinging Redunda: \(error)")
    }
    func statusChanged(newStatus: Bool) {
        print("new status happened! status: \(newStatus)")
    }
    func pinged(response: RedundaPingResponse) {
        print("pinged Redunda")
    }
}
