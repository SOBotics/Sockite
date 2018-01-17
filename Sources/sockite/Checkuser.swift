import Foundation

class Checkuser: Command {
    init() {
        super.init(syntax: ["checkuser"], args: 2, exec: { msg, args in
            let session = URLSession(configuration: .default)
            dataTask?.cancel()
            if var urlComponents = URLComponents(string: "https://api.stackexchange.com/2.2/users/\(user)/questions") {
                urlComponents.query = "pagesize=100&order=desc&sort=activity&site=stackoverflow&filter=!9YdnSEcyO&key=OJ*iP6ih)G0W1CQFgKllSg(("
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
                        print(String(data: data, encoding: .utf8)!)
                    } else {
                        print("unknown error")
                    }
                }
                dataTask?.resume()
            }
        })
    }
}
