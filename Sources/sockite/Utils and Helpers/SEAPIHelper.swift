import Foundation

class SEAPIHelper {
    static func getBadges(_ callback: @escaping (BadgeReciepents) -> ()) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/badges/63/recipients") {
            urlComponents.query = "site=stackoverflow&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                Log.handle(error: "Unable to build API URL!", consoleOutputPrefix: "SEAPIHelper")
                return
            }
            while backoff { // don't execute when backoff required
                Log.logWarning("Backing off", consoleOutputPrefix: "SEAPIHelper")
                sleep(5)
            }
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil; session.finishTasksAndInvalidate() }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                     Log.handle(error: "Invalid network response \(response.statusCode)", consoleOutputPrefix: "SEAPIHelper")
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(BadgeReciepents.self, from: data)
                        if let quotaRemaining = json.quota_remaining {
                            quota = quotaRemaining
                        }
                        if let backoff = json.backoff {
                            self.handleBackoff(backoff)
                        }
                        callback(json)
                    } catch {
                        Log.handle(error: "An error occurred while decoding JSON: \(error.localizedDescription)", consoleOutputPrefix: "SEAPIHelper")
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    static func getQuestions(ofUser user: String, _ callback: @escaping (QuestionJSON) -> ()) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/questions") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!)rFTNOX9*UlEK6EnL*f*&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                Log.handle(error: "Unable to build API URL!", consoleOutputPrefix: "SEAPIHelper")
                return
            }
            while backoff { // don't execute when backoff required
                Log.logWarning("Backing off", consoleOutputPrefix: "SEAPIHelper")
                sleep(5)
            }
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil; session.finishTasksAndInvalidate() }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    Log.handle(error: "Invalid network response \(response.statusCode)", consoleOutputPrefix: "SEAPIHelper")
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(QuestionJSON.self, from: data)
                        if let quotaRemaining = json.quota_remaining {
                            quota = quotaRemaining
                        }
                        if let backoff = json.backoff {
                            self.handleBackoff(backoff)
                        }
                        callback(json)
                    } catch {
                        Log.handle(error: "An error occurred while decoding JSON: \(error.localizedDescription)", consoleOutputPrefix: "SEAPIHelper")
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    static func getAnswers(ofUser user: String, _ callback: @escaping (AnswerJSON) -> ()) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/answers") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!-*jbN.L_QwxL&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                Log.handle(error: "Unable to build API URL!", consoleOutputPrefix: "SEAPIHelper")
                return
            }
            while backoff { // don't execute when backoff required
                Log.logWarning("Backing off", consoleOutputPrefix: "SEAPIHelper")
                sleep(5)
            }
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil; session.finishTasksAndInvalidate() }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    Log.handle(error: "Invalid network response \(response.statusCode)", consoleOutputPrefix: "SEAPIHelper")
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(AnswerJSON.self, from: data)
                        if let quotaRemaining = json.quota_remaining {
                            quota = quotaRemaining
                        }
                        if let backoff = json.backoff {
                            self.handleBackoff(backoff)
                        }
                        callback(json)
                    } catch {
                        Log.handle(error: "An error occurred while decoding JSON: \(error.localizedDescription)", consoleOutputPrefix: "SEAPIHelper")
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    static func handleBackoff(_ secs: Int) {
        Log.log("[SEAPIHelper] Backoff requested for \(secs) seconds!", withColor: .lightRed)
        backoff = true
        let finalSecs = secs + 60
        sleep(UInt32(finalSecs))
        backoff = false
    }
}
