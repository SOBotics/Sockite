// swift-tools-version:3.2
import PackageDescription

let package = Package(
    name: "sockite",
    dependencies: [
        .Package(url: "https://github.com/SOBotics/SwiftChatSE", majorVersion: 5),
        .Package(url: "https://github.com/SOBotics/SwiftRedunda.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/jpsim/Yams.git", majorVersion: 1),
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2)
    ]
)
