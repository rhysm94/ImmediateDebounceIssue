// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ImmediateDebounceIssue",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
 ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ImmediateDebounceIssue",
      targets: ["ImmediateDebounceIssue"]
    ),
  ],
  dependencies: [
    // Swift Clocks from PointFree
    .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ImmediateDebounceIssue",
      dependencies: [
        // Swift Clocks
        .product(name: "Clocks", package: "swift-clocks"),
      ]
    ),
    .testTarget(
      name: "ImmediateDebounceIssueTests",
      dependencies: [
        "ImmediateDebounceIssue",
        .product(name: "Clocks", package: "swift-clocks"),
      ]
    ),
  ]
)
