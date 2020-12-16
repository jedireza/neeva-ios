// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "neeva-ios-support",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "neeva-ios-support",
            targets: ["neeva-ios-support"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Apollo",
                 url: "https://github.com/apollographql/apollo-ios.git",
                 .upToNextMinor(from: "0.38.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "neeva-ios-support",
            dependencies: ["Apollo"],
            exclude: ["operationIDs.json", "schema.json", "queries.graphql"]
        ),
        .testTarget(
            name: "neeva-ios-supportTests",
            dependencies: ["neeva-ios-support"]),
    ]
)
