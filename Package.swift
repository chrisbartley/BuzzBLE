// swift-tools-version:5.1

import PackageDescription

let package = Package(
      name: "BuzzBLE",
      platforms: [
         .iOS(.v10), .macOS(.v10_14)
      ],
      products: [
         // Products define the executables and libraries produced by a package, and make them visible to other packages.
         .library(
               name: "BuzzBLE",
               targets: ["BuzzBLE"]),
      ],
      dependencies: [
         .package(url: "git@github.com:BirdBrainTechnologies/BirdbrainBLE.git", "0.6.0"..<"0.7.0")
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
