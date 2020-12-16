# neeva-ios-support

Private repo for features of the Neeva app we don’t want to make open-source.

Open `neeva-ios-support.xcworkspace` to see both projects at once.

## Updating the schema and `API.swift`

Copy the latest `schema.json` file to `Sources/NeevaSupport/schema.json`

Update `Codegen/Sources/Codegen/queries.graphql` to contain the queries you want to use.
The name of the query (with `Query` appended) will be used as the Swift class name.

In Xcode, select the “Codegen” scheme and click the run button.
