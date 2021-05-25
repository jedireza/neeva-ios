Neeva for iOS [![codebeat badge](https://codebeat.co/badges/67e58b6d-bc89-4f22-ba8f-7668a9c15c5a)](https://codebeat.co/projects/github-com-mozilla-neeva-ios)  [![codecov](https://codecov.io/gh/mozilla-mobile/neeva-ios/branch/main/graph/badge.svg)](https://codecov.io/gh/mozilla-mobile/neeva-ios/branch/main)
===============

Download on the [App Store](https://alpha.neeva.co).

This branch (main)
-----------

This branch works with [Xcode 12.3](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_12.3/Xcode_12.3.xip), Swift 5.3 and supports iOS 12.0 and above.

Please make sure you aim your pull requests in the right direction.

For bug fixes and features for a specific release use the version branch.

Getting involved
----------------

Want to contribute but don't know where to start? Here is a list of [issues that are contributor friendly](https://github.com/neevaco/neeva-ios-phoenix/labels/Contributor%20OK)

Building the code
-----------------

1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
1. Install Carthage, Node, and a Python 3 virtualenv for localization scripts:
    ```shell
    brew update
    brew install carthage
    brew install node
    pip3 install virtualenv
    ```
1. Clone the repository:
    ```shell
    git clone https://github.com/mozilla-mobile/firefox-ios
    ```
1. Pull in the project dependencies:
    ```shell
    cd firefox-ios
    sh ./bootstrap.sh
    ```
1. Open `Client.xcodeproj` in Xcode.
1. Build the `Fennec` scheme in Xcode.

## Building User Scripts

User Scripts (JavaScript injected into the `WKWebView`) are compiled, concatenated and minified using [webpack](https://webpack.js.org/). User Scripts to be aggregated are placed in the following directories:

```
/Client
|-- /Frontend
    |-- /UserContent
        |-- /UserScripts
            |-- /AllFrames
            |   |-- /AtDocumentEnd
            |   |-- /AtDocumentStart
            |-- /MainFrame
                |-- /AtDocumentEnd
                |-- /AtDocumentStart
```

This reduces the total possible number of User Scripts down to four. The compiled output from concatenating and minifying the User Scripts placed in these folders resides in `/Client/Assets` and are named accordingly:

* `AllFramesAtDocumentEnd.js`
* `AllFramesAtDocumentStart.js`
* `MainFrameAtDocumentEnd.js`
* `MainFrameAtDocumentStart.js`

To simplify the build process, these compiled files are checked-in to this repository. When adding or editing User Scripts, these files can be re-compiled with `webpack` manually. This requires Node.js to be installed and all required `npm` packages can be installed by running `npm install` in the root directory of the project. User Scripts can be compiled by running the following `npm` command in the root directory of the project:

```
npm run build
```

## SwiftUI Previews
To perform authenticated requests in SwiftUI previews, create a `dev-token.txt` file in `NeevaSupport` and copy over your `httpd~login` token from the app or website. This file is ignored by Git, but will be copied over when creating the preview.

## Updating the schema and `API.swift`

Copy the latest `schema.json` file to `Shared/API/schema.json`

You can get the latest `schema.json` file from the monorepo:
```
cd client/packages/neeva-lib
yarn install && yarn build
```
You will then see a `gen` directory with the generated `gen/graphql/schema.json` file.

Add your query or mutation to one of the `.graphql` files in `Codegen/Sources/Codegen/` (grouped approximately by theme).
The name of the query/mutation (with `Query` or `Mutation` appended) will be used as the Swift struct name.

In Xcode, select the “Codegen” scheme and click the run button to regenerate `API.swift` with Swift bindings to the queries/mutations.

For queries, implement a `QueryController` subclass to interface with SwiftUI:

- The `Query` type is the GraphQL query type
- The `Data` type is the type you provide to your SwiftUI code. This is typically nested in the `Data` typeof the `Query` type.
  - I recommend defining a `typealias` in your subclass to make it easier for users to reference your data type
- Implement `func reload() -> Void` by calling  `self.perform(query:)` with your desired query
  - To add a refresh control to a `List` or `Form`, pass your `QueryController` subclass into `List { ... }.refreshControl(refreshing:)`
- If your `Data` type is different from the `Data` type returned by the raw query, implement `class func processData(_ data: Query.Data) -> Data` to convert the raw query result to the desired type
  - If you need to access information from the query that was sent to the server, instead implement `class func processData(_ data: Query.Data, for query: Query) -> Data` which calls `processData(data)` by default.
- See `SuggestionsController` for an example of how to handle a query that responds to user input.

There is currently less infrastructure for calling mutations, but there’s a convenience API `SomeMutation().perform { result in ... }` that provides the authentication and other headers, and converts a “successful” result with errors into a failure.

## Contributing

Want to contribute to this repository? Check out [Contributing Guidelines](https://github.com/mozilla-mobile/firefox-ios/blob/main/CONTRIBUTING.md)
