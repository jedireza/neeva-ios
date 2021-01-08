// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(name: "Apollo",
                 url: "https://github.com/apollographql/apollo-ios.git",
                 .upToNextMinor(from: "0.38.3"))
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: [.product(name: "ApolloCodegenLib", package: "Apollo")],
            exclude: ["acl.graphql", "misc.graphql", "fragments.graphql", "spaces.graphql", "suggestions.graphql", "user-info.graphql"]
        )
    ]
)
