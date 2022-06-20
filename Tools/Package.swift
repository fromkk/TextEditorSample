// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.47.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.49.10")
    ],
    targets: [.target(name: "Tools", path: "")]
)
