import PackageDescription

let package = Package(
    name: "reach-the-good",
    dependencies: [
        .Package(url: "https://github.com/takebayashi/swiftra.git", majorVersion: 0)
    ]
)
