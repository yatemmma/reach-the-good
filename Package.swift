import PackageDescription

let package = Package(
  name: "reach-the-tottori",
  dependencies: [
    .Package(url: "https://github.com/kylef/Curassow.git", majorVersion: 0, minor: 2),
    .Package(url: "https://github.com/groue/GRMustache.swift", majorVersion: 1, minor: 0),
  ]
)
