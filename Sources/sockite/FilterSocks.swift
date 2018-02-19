import Foundation

class FilterSocks {
    static func getScoreOfUserAndTarget(user: String, _ callback: @escaping (Int, String, String, Error) -> ()) {
        let qRes = getScoreOfQuestions(user: user)
    }
    
    
    // ==== QUESTION FILTERS ====
    static func getScoreOfQuestions(user: String) -> [Int : (Double, [String])] {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/questions") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!0V-ZwUEu0wMbto7XHeIh96H_K&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                return [:]
            }
            print(url)
            
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    
                }
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(QuestionJSON.self, from: data)
                        guard let items = json.items else {
                            return
                        }
                        
                        // START FILTERING
                        var socks: [Int: [(Double, String?)]] = [:]
                        let filters = [sameAnswerer75, sameAnswerer100, haveUpvote]
                        for filter in filters {
                            let filterRes = filter(items)
                            for (user, reason) in filterRes {
                                socks[user]!.append(reason)
                            }
                        }
                        // DONE FILTERING, RETURN RESULT
                        var resDict: [Int : (Double, [String])] = [:]
                        for (sock, ress) in socks {
                            var finalScore = 0.0
                            var reasons: [String] = []
                            for res in ress {
                                finalScore += res.0
                                if let reason = res.1 {
                                    reasons.append(reason)
                                }
                            }
                            resDict[sock] = (finalScore, reasons)
                        }
                        
                        
                    } catch let jsonError {
                    }
                } else {
                }
            }
            dataTask?.resume()
        }
        return [:]
    }
    
    // 75% of accepted answers answered by same user
    static func sameAnswerer75(_ items: [QuestionJSON.Item]) -> [Int : (Double, String?)] {
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
        var possibleSock: [Int : Double] = [:]
        for (key, val) in counts {
            if Double(val) / Double(answerOwners.count) > 0.75 {
                possibleSock[key] = Double(val) / Double(answerOwners.count) * 6
            }
        }
        
        var responseDict: [Int : (Double, String?)] = [:]
        for (acc, score) in possibleSock {
            responseDict[acc] = (score, "\(score / 6.0 * 100.0)% of accepted answers are answered by same user (user: [\(acc)](https://stackoverflow.com/users/\(acc))")
        }
        
        return responseDict
    }
    
    // 100% of answers answered by same user
    static func sameAnswerer100(_ items: [QuestionJSON.Item]) -> [Int : (Double, String?)] {
        if items.count > 4 {
            return [:]
        }
        var answerOwners: [Int] = []
        for item in items {
            for answer in item.answers! {
                answerOwners.append(answer.owner!.user_id!)
            }
        }
        
        for answerOwner in answerOwners {
            if answerOwners[0] != answerOwner {
                return [:]
            }
        }
        
        return [answerOwners[0] : (6.0, "100% of answers are answered by same user (user: [\(answerOwners[0])](https://stackoverflow.com/users/\(answerOwners[0])")]
    }
    
    // all questions have an upvote
    static func haveUpvote(_ items: [QuestionJSON.Item]) -> [Int : (Double, String?)] {
        for item in items {
            if item.up_vote_count! <= 0 {
                return [:]
            }
        }
        return [-1 : (2.3, "100% of questions have 1 upvote")]
    }
    
    // ==== ANSWER FILTERS ====
    static func getScoreOfAnswers(user: String) -> [Int : (Double, [String])] {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/answers") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!-*jbN.L_QwxL"
            guard let url = urlComponents.url else {
                return [:]
            }
            print(url)
            
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    
                }
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data, response.statusCode == 200 {
                }
            }
        }
        return [:]
    }
    
    // 100%
}

