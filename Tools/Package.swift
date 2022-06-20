// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.47.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.10"),
        .package(url: "https://github.com/SwiftGen/SwiftGen", from: "6.5.1"),
        .package(url: "https://github.com/uber/mockolo.git", from: "1.7.0")
    ],
    targets: [.target(name: "Tools", path: "")]
)
