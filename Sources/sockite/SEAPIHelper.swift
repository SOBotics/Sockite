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
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil; session.finishTasksAndInvalidate() }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                     Log.handle(error: "Invalid network response \(response.statusCode)", consoleOutputPrefix: "SEAPIHelper")
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(BadgeReciepents.self, from: data)
                        callback(json)
                    } catch {
                        Log.handle(error: "An error occurred while decoding JSON: \(error.localizedDescription)", consoleOutputPrefix: "SEAPIHelper")
                    }
                }
            }
            dataTask?.resume()
        }
    }
}
