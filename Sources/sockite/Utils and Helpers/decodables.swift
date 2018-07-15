struct QuestionJSON: Decodable {
    struct Item: Decodable {
        struct Answer: Decodable {
            var owner: User?
            var is_accepted: Bool?
            var answer_id: Int?
        }
        var tags: [String]?
        var answers: [Answer]?
        var owner: User?
        var is_answered: Bool?
        var accepted_answer_id: Int?
        var question_id: Int?
        var link: String?
        var title: String?
        var up_vote_count: Int?
        var down_vote_count: Int?
    }
    var items: [Item]?
    var quota_remaining: Int?
    var backoff: Int?
}

struct User: Decodable {
    var reputation: Int?
    var user_id: Int?
    var display_name: String?
    var link: String?
}

struct AnswerJSON: Decodable {
    struct Item: Decodable {
        var owner: User?
        var down_vote_count: Int?
        var up_vote_count: Int?
        var is_accepted: Bool?
        var answer_id: Int?
    }
    var items: [Item]?
    var quota_remaining: Int?
    var backoff: Int?
}

struct BadgeReciepents: Decodable {
    struct Item: Decodable {
        var user: User?
    }
    var items: [Item]?
    var quota_remaining: Int?
    var backoff: Int?
}
