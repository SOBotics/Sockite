struct CheckuserJSON: Decodable {
    struct Owner: Decodable {
        var reputation: Int
        var user_id: Int
        var display_name: String
        var link: String
    }
    struct Item: Decodable {
        struct Answer: Decodable {
            var owner: Owner
            var is_accepted: Bool
            var answer_id: Int
        }
        var tags: [String]
        var answers: [Answer]
        var owner: Owner
        var is_answered: Bool
        var accepted_answer_id: Int
        var question_id: Int
        var link: String
        var title: String
    }
    var items: [Item]
}
