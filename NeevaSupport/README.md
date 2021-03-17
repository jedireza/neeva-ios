# neeva-ios-support

Private repo for features of the Neeva app we don’t want to make open-source.

Open `neeva-ios-support.xcworkspace` to see both projects at once.

## Using the demo app

1. In the main Neeva app on your device, go to the settings screen and tap the version number several times.
1. Scroll further down and tap the “Neeva token” entry to copy it
1. Select the “Neeva iOS Support” app scheme in Xcode
1. Build and run the support app on your target device
1. Paste the token into the token input in the support app
1. Tap “Get user info” to check your username and save the token to the keychain so you don’t have to re-enter it.
1. Switch to the relevant tab to test your feature.

## SwiftUI Previews
To perform authenticated requests in SwiftUI previews, create a `dev-token.txt` file in `Sources/NeevaSupport` and copy over your `httpd~login` token from the app or website. This file is ignored by Git, but will be copied over when creating the preview.

## Updating the schema and `API.swift`

Copy the latest `schema.json` file to `Sources/NeevaSupport/schema.json`

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
