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

## Updating the schema and `API.swift`

Copy the latest `schema.json` file to `Sources/NeevaSupport/schema.json`

Update `Codegen/Sources/Codegen/queries.graphql` to contain the queries you want to use.
The name of the query (with `Query` appended) will be used as the Swift class name.

In Xcode, select the “Codegen” scheme and click the run button.
