import Foundation
import ApolloCodegenLib

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent() // Result: Sources folder
    .deletingLastPathComponent() // Result: Codegen folder
    .deletingLastPathComponent() // Result: neeva-ios-support source root folder

func / (dir: URL, folderName: String) -> URL {
    dir.apollo.childFolderURL(folderName: folderName)
}

do {
    try ApolloCodegen.run(
        from: sourceRootURL / "Codegen" / "Sources" / "Codegen",
        with: sourceRootURL / "Codegen" / "ApolloCLI",
        options: ApolloCodegenOptions(
            targetRootURL: sourceRootURL / "Sources" / "NeevaSupport"
        )
    )
} catch {
    print(error)
    exit(1)
}
