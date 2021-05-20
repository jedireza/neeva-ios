import Foundation
import ApolloCodegenLib

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Result: Sources folder
    .deletingLastPathComponent() // Result: Codegen folder
    .deletingLastPathComponent() // Result: neeva-ios-phoenix source root folder

func / (dir: URL, folderName: String) -> URL {
    dir.apollo.childFolderURL(folderName: folderName)
}

do {
    try ApolloCodegen.run(
        from: parentFolderOfScriptFile,
        with: sourceRootURL / "Codegen" / "ApolloCLI",
        options: ApolloCodegenOptions(
            targetRootURL: sourceRootURL / "Shared" / "API"
        )
    )
} catch {
    print(error)
    exit(1)
}
