// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NeevaSupport",
    // we don’t support macOS yet but some of our packages do and the default is v10.10
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "NeevaSupport",
            targets: ["NeevaSupport"]),
    ],
    dependencies: [
        .package(name: "Apollo", url: "https://github.com/apollographql/apollo-ios", .upToNextMinor(from: "0.42.0")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", .upToNextMajor(from: "4.2.1")),
        .package(url: "https://github.com/crelies/RemoteImage", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "4.2.1")),
        .package(name: "Introspect", url: "https://github.com/siteline/SwiftUI-Introspect", .upToNextMinor(from: "0.1.3")),
        .package(name: "Reachability", url: "https://github.com/ashleymills/Reachability.swift", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NeevaSupport",
            dependencies: ["Apollo", "KeychainAccess", "RemoteImage", "Defaults", "Introspect", "Reachability"],
            exclude: ["operationIDs.json", "schema.json"],
            resources: [.copy("dev-token.txt")]
        ),
    ]
)
