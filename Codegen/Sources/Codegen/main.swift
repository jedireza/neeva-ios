import ApolloCodegenLib
import Foundation

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL =
    parentFolderOfScriptFile
    .deletingLastPathComponent()  // Result: Sources folder
    .deletingLastPathComponent()  // Result: Codegen folder
    .deletingLastPathComponent()  // Result: neeva-ios source root folder

func / (dir: URL, folderName: String) -> URL {
    dir.apollo.childFolderURL(folderName: folderName)
}

do {
    let targetRootURL = sourceRootURL / "Shared" / "API"

    let schema = targetRootURL.appendingPathComponent("schema.json")
    let codegenEngine: ApolloCodegenOptions.CodeGenerationEngine = .default
    let outputFileURL: URL
    switch codegenEngine {
    case .typescript:
        outputFileURL = targetRootURL.appendingPathComponent("API.swift")
    }

    let operationIDsURL = targetRootURL.appendingPathComponent("operationIDs.json")

    let options = ApolloCodegenOptions(
        codegenEngine: codegenEngine,
        operationIDsURL: operationIDsURL,
        outputFormat: .singleFile(atFileURL: outputFileURL),
        urlToSchemaFile: schema,
        downloadTimeout: 30.0
    )

    try ApolloCodegen.run(
        from: parentFolderOfScriptFile,
        with: sourceRootURL / "Codegen" / "ApolloCLI",
        options: options
    )
    let compiledFileURL = targetRootURL / "API.swift"
    let compiledFile =
        try "// swift-format-ignore-file\n".data(using: .utf8)! + Data(contentsOf: compiledFileURL)
    try compiledFile.write(to: compiledFileURL)
} catch {
    print(error)
    exit(1)
}
