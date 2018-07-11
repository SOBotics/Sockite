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
               //getScoreOfAnswers(user: user, callback: { aRes, err in // NEEDS TO BE FIXED
                    Log.logInfo("Finishing up...", consoleOutputPrefix: "FilterSocks")
//                    if let err = err {
//                        callback(nil, err)
//                    }
                    for (qSock, data) in qRes {
                        Log.logInfo("Building question results", consoleOutputPrefix: "FilterSocks")
                        if let sock = resDict[qSock] {
                            Log.logInfo("Appending to previous report", consoleOutputPrefix: "FilterSocks")
                            let newScore = sock.0 + data.0
                            let newReason = sock.1 + ", " + data.1.joined(separator: ", ")
                            resDict[qSock] = (newScore, newReason)
                        } else {
                            Log.logInfo("Building new report", consoleOutputPrefix: "FilterSocks")
                            resDict[qSock] = (data.0, data.1.joined(separator: ", "))
                        }
                    }
//                    if let aRes = aRes {
//                        for (aSock, data) in aRes {
//                            if let sock = resDict[aSock] {
//                                let newScore = sock.0 + data.0
//                                let newReason = sock.1 + ", " + data.1.joined(separator: ", ")
//                                resDict[aSock] = (newScore, newReason)
//                            }
//                        }
//                    }
                    if !resDict.isEmpty {
                        callback(resDict, nil)
                    } else {
                        callback(nil, nil)
                    }
                //})
            } else {
                callback(nil, nil)
            }
        })
    }
    
    
    // ==== QUESTION FILTERS ====
    static func getScoreOfQuestions(user: String, callback: @escaping ([Int : (Double, [String])]?, Error?) -> ()) {
        Log.logInfo("Scanning questions of user \(user)", consoleOutputPrefix: "FilterSocks")
        SEAPIHelper.getQuestions(ofUser: user) { json in
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
            do {
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
                Log.handle(error: "Something went wrong with the filters!")
                callback(nil, error)
            }
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
        if items.count > 4 && items.count == 1 {
            return [:]
        }
        var answerOwners: [Int] = []
        for item in items {
            Log.logInfo("Item in sameAnswerer100 queued", consoleOutputPrefix: "FilterSocks")
            guard let answers = item.answers else {
                Log.logWarning("item.answers is nil!")
                continue
            }
            Log.logInfo("item.answers is not nil, iterating", consoleOutputPrefix: "FilterSocks")
            for answer in answers {
                answerOwners.append(answer.owner!.user_id!)
            }
        }
        
        if answerOwners.isEmpty {
            Log.logInfo("sameAnswerer100 passed (no answer owners)", consoleOutputPrefix: "FilterSocks")
            return [:]
        }
        
        for answerOwner in answerOwners {
            if answerOwners[0] != answerOwner {
                Log.logInfo("sameAnswerer100 passed", consoleOutputPrefix: "FilterSocks")
                return [:]
            }
        }
        
        Log.logInfo("sameAnswerer100 failed", consoleOutputPrefix: "FilterSocks")
        return [answerOwners[0] : (6.0, "100% of answers are answered by same user (user: [\(answerOwners[0])](https://stackoverflow.com/users/\(answerOwners[0]))")]
    }
    
    // all questions have an upvote
    static func haveUpvote(_ items: [QuestionJSON.Item]) throws -> [Int : (Double, String?)] {
        Log.logInfo("Testing haveUpvote", consoleOutputPrefix: "FilterSocks")
        for item in items {
            guard let upvoteCount = item.up_vote_count else {
                Log.logWarning("item.up_vote_count is nil!")
                broadcastMessage("Error occured while proccesing haveUpvote, see the log for more details (@paper)")
                continue
            }
            if upvoteCount <= 0 {
                Log.logInfo("haveUpvote passed")
                return [:]
            }
        }
        
        Log.logInfo("haveUpvote failed")
        return [-1 : (2.3, "100% of questions have at lease 1 upvote")]
    }
    
    // ==== ANSWER FILTERS ====
    static func getScoreOfAnswers(user: String, callback: @escaping ([Int : (Double, [String])]?, Error?) -> ()) {
        Log.logInfo("Scanning answers of user \(user)", consoleOutputPrefix: "FilterSocks")
        SEAPIHelper.getAnswers(ofUser: user) { json in
            guard let items = json.items else {
                callback(nil, FilterSocksError.invalidJson)
                return
            }
                        
            if items.isEmpty {
                callback([:], nil)
                return
            }
        }
    }
    
}

