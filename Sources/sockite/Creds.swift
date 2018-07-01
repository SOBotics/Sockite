struct Creds: Codable {
    var redunda_key: String
    var email: String
    var password: String
    var rooms: [Int]
    var sqlite_file_path: String
}
