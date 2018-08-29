import Foundation

class Threads: Command {
    init() {
        super.init(syntax: ["threads"], args: 1, exec: { msg, _, room in
            let task = Process()
            try! task.launchPath = String(contentsOf: URL(fileURLWithPath: "proc.sh"), encoding: .utf8)
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)!
            room.postMessage(output)
        })
        self.description = "to get all the threads belonging to this process, for debug uses only"
    }
}
