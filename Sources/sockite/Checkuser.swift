import Foundation

class Checkuser: Command {
    init() {
        super.init(syntax: ["checkuser"], args: 3, exec: { msg, args in
            let session = URLSession(configuration: .default)
            dataTask?.cancel()
            if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(args[1]);\(args[2])/questions") {
                urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!9YdnSEcyO&key=OJ*iP6ih)G0W1CQFgKllSg(("
                guard let url = urlComponents.url else {
                    return
                }
                print(url)
                
                dataTask = session.dataTask(with: url) { data, response, error in
                    defer { dataTask = nil }
                    let ponse = response as! HTTPURLResponse
                    print(ponse.statusCode)
                    var resToChat = ""
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        do {
                            let json = try JSONDecoder().decode(CheckuserJSON.self, from: data)
                            guard let items = json.items else {
                                return
                            }
                            for item in items {
                                if let answers = item.answers {
                                    for answer in answers {
                                        if answer.owner!.user_id! != item.owner!.user_id! {
                                            if String(answer.owner!.user_id!) == args[1] || String(answer.owner!.user_id!) == args[2] {
                                                if resToChat == "" {
                                                    resToChat.append("Questions answered by target user:")
                                                }
                                                resToChat.append("\nQ: \(item.link!); A: https://stackoverflow.com/a/\(String(answer.answer_id!))")
                                            }
                                        }
                                    }
                                }
                            }
                            room.postMessage(resToChat)
                        } catch let jsonError {
                            room.postMessage("Error occured: `\(jsonError.localizedDescription)` cc @paper")
                        }
                    } else {
                        room.postMessage("Unknown error at `Checkuser.swift#L41` cc @paper")
                    }
                }
                dataTask?.resume()
            }
        })
    }
}
