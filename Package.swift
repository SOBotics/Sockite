// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sockite",
    dependencies: [
        .package(url: "git://github.com/SOBotics/SwiftChatSE", from: "5.0.0"),
    ],
    targets: [
        .target(name: "sockite", dependencies: ["SwiftChatSE"]),
    ]
)
