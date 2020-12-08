// swift-tools-version:5.1

import PackageDescription

let package = Package(
      name: "BuzzBLE",
      platforms: [
         .iOS(.v10), .macOS(.v10_14)
      ],
      products: [
         .library(
               name: "BuzzBLE",
               targets: ["BuzzBLE"]),
      ],
      dependencies: [
         .package(url: "git@github.com:chrisbartley/BirdbrainBLE.git", "0.7.0"..<"0.8.0")
      ],
      targets: [
         .target(
               name: "BuzzBLE",
               dependencies: ["BirdbrainBLE"]),
         .testTarget(
               name: "BuzzBLETests",
               dependencies: ["BuzzBLE"]),
      ]
)
