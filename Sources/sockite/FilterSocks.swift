import Foundation

class FilterSocks {
    
    enum FilterSocksError: Error {
        case invalidJson
        case invalidUrlComponents
    }
    
    //                                                                  ([target user id: (score, reason)], error)
    static func getScoreOfUserAndTarget(user: String, _ callback: @escaping ([Int: (Double, String)]?, Error?) -> ()) {
        getScoreOfQuestions(user: user, callback: { qRes, err in
            var resDict: [Int: (Double, String)] = [:]
            if let err = err {
                callback(nil, err)
            }
            if let qRes = qRes {
                getScoreOfAnswers(user: user, callback: { aRes, err in
                    if let err = err {
                        callback(nil, err)
                    }
                    if let aRes = aRes {
                        for (qSock, data) in qRes {
                            if let sock = resDict[qSock] {
                                let newScore = sock.0 + data.0
                                let newReason = sock.1 + ", " + data.1.joined(separator: ", ")
                                resDict[qSock] = (newScore, newReason)
                            }
                        }
                        for (aSock, data) in aRes {
                            if let sock = resDict[aSock] {
                                let newScore = sock.0 + data.0
                                let newReason = sock.1 + ", " + data.1.joined(separator: ", ")
                                resDict[aSock] = (newScore, newReason)
                            }
                        }
                    }
                })
            }
            if !resDict.isEmpty {
                callback(resDict, nil)
            } else {
                callback(nil, nil)
            }
        })
    }
    
    
    // ==== QUESTION FILTERS ====
    static func getScoreOfQuestions(user: String, callback: @escaping ([Int : (Double, [String])]?, Error?) -> ()) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/questions") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!0V-ZwUEu0wMbto7XHeIh96H_K&key=OJ*iP6ih)G0W1CQFgKllSg(("
            guard let url = urlComponents.url else {
                callback(nil, FilterSocksError.invalidUrlComponents)
                return
            }
            Log.logInfo(url.absoluteString)
            
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(QuestionJSON.self, from: data)
                        guard let items = json.items else {
                            callback(nil, FilterSocksError.invalidJson)
                            return
                        }
                        
                        if items.isEmpty {
                            callback([:], nil)
                            return
                        }
                        
                        // START FILTERING
                        var socks: [Int: [(Double, String?)]] = [:]
                        let filters = [sameAnswerer75, sameAnswerer100, haveUpvote]
                        for filter in filters {
                            let filterRes = try filter(items)
                            for (user, reason) in filterRes {
                                if socks[user] != nil {
                                    socks[user]!.append(reason)
                                } else {
                                    socks[user] = [reason]
                                }
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
                        callback(resDict, nil)
                        
                    } catch {
                        callback(nil, error)
                    }
                } else {
                }
            }
            dataTask?.resume()
        }
    }
    
    // 75% of accepted answers answered by same user
    static func sameAnswerer75(_ items: [QuestionJSON.Item]) -> [Int : (Double, String?)] {
        if items.count <= 4 {
            return [:]
        }
        var answerOwners: [Int] = []
        for item in items {
            guard let answers = item.answers else {
                Log.logWarning("item.answers is nil, continuing...")
                continue
            }
            for answer in answers {
                guard let isAccepted = answer.is_accepted else {
                    Log.logWarning("answer.is_accepted is nil!")
                    broadcastMessage("Error occured while proccesing sameAnswerer75, see the log for more details (@paper)")
                    continue
                }
                if isAccepted {
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
            guard let answers = item.answers else {
                Log.logWarning("item.answers is nil!")
                broadcastMessage("Error occured while proccesing sameAnswerer100, see the log for more details (@paper)")
                continue
            }
            for answer in answers {
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
    static func haveUpvote(_ items: [QuestionJSON.Item]) throws -> [Int : (Double, String?)] {
        for item in items {
            guard let upvoteCount = item.up_vote_count else {
                Log.logWarning("item.up_vote_count is nil!")
                broadcastMessage("Error occured while proccesing haveUpvote, see the log for more details (@paper)")
                continue
            }
            if upvoteCount <= 0 {
                return [:]
            }
        }
        return [-1 : (2.3, "100% of questions have 1 upvote")]
    }
    
    // ==== ANSWER FILTERS ====
    static func getScoreOfAnswers(user: String, callback: @escaping ([Int : (Double, [String])]?, Error?) -> ()) {
        var dataTask: URLSessionDataTask?
        let session = URLSession(configuration: .default)
        
        if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/answers") {
            urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!-*jbN.L_QwxL"
            guard let url = urlComponents.url else {
                callback(nil, FilterSocksError.invalidUrlComponents)
                return
            }
            Log.logInfo(url.absoluteString)
            
            dataTask = session.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                let response = response as! HTTPURLResponse
                if response.statusCode != 200 {
                    
                }
                if let data = data, response.statusCode == 200 {
                    do {
                        let json = try JSONDecoder().decode(QuestionJSON.self, from: data)
                        guard let items = json.items else {
                            callback(nil, FilterSocksError.invalidJson)
                            return
                        }
                        
                        if items.isEmpty {
                            callback([:], nil)
                            return
                        }
                    } catch let jsonError {
                        callback(nil, jsonError)
                    }
                }
            }
        }
    }
    
}

