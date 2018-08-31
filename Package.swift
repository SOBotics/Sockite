// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "sockite",
    dependencies: [
        .package(url: "https://github.com/SOBotics/SwiftChatSE.git", .exact("5.0.7")),
        .package(url: "https://github.com/SOBotics/SwiftRedunda.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.0.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", .upToNextMinor(from: "0.11.0"))
    ],
    targets: [
        .target(
            name: "sockite",
            dependencies: ["SwiftChatSE", "SwiftRedunda", "Yams", "Rainbow", "SQLite"]
        )
    ]
)
