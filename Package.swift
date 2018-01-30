// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sockite",
    dependencies: [
        .package(url: "https://github.com/SOBotics/SwiftChatSE.git", from: "5.0.0"),
        .package(url: "https://github.com/SOBotics/SwiftRedunda.git", from: "0.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "0.5.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.5.0")
    ],
    targets: [
        .target(name: "sockite", dependencies: ["SwiftChatSE", "SwiftRedunda", "Yams", "SwiftyBeaver"]),
    ]
)
