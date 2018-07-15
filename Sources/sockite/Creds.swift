struct Creds: Codable {
    var redunda_key: String
    var email: String
    var password: String
    var rooms: [Int]
    var data_dir: String
}
