import ApolloCodegenLib
import Foundation

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL =
    parentFolderOfScriptFile
    .deletingLastPathComponent()  // Result: Sources folder
    .deletingLastPathComponent()  // Result: Codegen folder
    .deletingLastPathComponent()  // Result: neeva-ios-phoenix source root folder

func / (dir: URL, folderName: String) -> URL {
    dir.apollo.childFolderURL(folderName: folderName)
}

do {
    let targetRootURL = sourceRootURL / "Shared" / "API"
    try ApolloCodegen.run(
        from: parentFolderOfScriptFile,
        with: sourceRootURL / "Codegen" / "ApolloCLI",
        options: ApolloCodegenOptions(targetRootURL: targetRootURL)
    )
    let compiledFileURL = targetRootURL / "API.swift"
    let compiledFile =
        try "// swift-format-ignore-file\n".data(using: .utf8)! + Data(contentsOf: compiledFileURL)
    try compiledFile.write(to: compiledFileURL)
} catch {
    print(error)
    exit(1)
}
