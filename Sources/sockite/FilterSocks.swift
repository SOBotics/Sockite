import Foundation

class FilterSocks {
    static func getScoreOfUserAndTarget(user: String, _ callback: @escaping (Int, String, String, Error) -> ()) {
        
    }
    
    static func getScoreOfQuestions(user: String) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/questions") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!0V-ZwUEu0wMbto7XHeIh96H_K&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                return
            }
            print(url)
            
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                let ponse = response as! HTTPURLResponse
                print(ponse.statusCode)
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(QuestionJSON.self, from: data)
                        guard let items = json.items else {
                            return
                        }
                        
                    } catch let jsonError {
                    }
                } else {
                }
            }
            dataTask?.resume()
        }
    }
    
    // 75% of accepted answers answered by same user
    static func sameAnswerer75(_ items: [QuestionJSON.Item]) -> [Int : (Float, String?)] {
        if items.count <= 4 {
            return [:]
        }
        var answerOwners: [Int] = []
        for item in items {
            for answer in item.answers! {
                if answer.is_accepted! {
                    answerOwners.append(answer.owner!.user_id!)
                }
            }
        }
        let counts = answerOwners.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        var possibleSock: [Int : Float] = [:]
        for (key, val) in counts {
            if Float(val) / Float(answerOwners.count) > 0.75 {
                possibleSock[key] = Float(val) / Float(answerOwners.count) * 6
            }
        }
        
        // build the response dict
        var responseDict: [Int : (Float, String?)] = [:]
        for (acc, score) in possibleSock {
            responseDict[acc] = (score, "\(score / 6.0 * 100.0)% of accepted answers are answered by same user (user: [\(acc)](https://stackoverflow.com/users/\(acc)")
        }
        
        return responseDict
    }
}

