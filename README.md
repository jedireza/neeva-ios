# neeva-ios-support

Private repo for features of the Neeva app we don’t want to make open-source.

Open `neeva-ios-support.xcworkspace` to see both projects at once.

## GraphQL support

1. Copy the latest `schema.json` file to `Sources/neeva-ios-support/schema.json`
2. Open a terminal and run:
   ```shellsession
   $ cd Codegen
   $ swift run
   ```
   This wll install the Apollo CLI and generate the API.swift file
