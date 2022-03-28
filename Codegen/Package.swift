// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    platforms: [
        .macOS(.v10_14)
    ],
    dependencies: [
        .package(
            name: "Apollo",
            url: "https://github.com/apollographql/apollo-ios",
            .upToNextMinor(from: "0.51.0"))
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: [.product(name: "ApolloCodegenLib", package: "Apollo")],
            exclude: [
                "logging.graphql", "misc.graphql", "search.graphql", "spaces.graphql",
                "suggestions.graphql",
            ]
        )
    ]
)
