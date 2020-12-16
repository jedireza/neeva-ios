import Foundation
import ApolloCodegenLib

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
    .apollo.parentFolderURL() // Result: Sources folder
    .apollo.parentFolderURL() // Result: Codegen folder
    .apollo.parentFolderURL() // Result: neeva-ios-support source root folder

let cliFolderURL = sourceRootURL
    .apollo.childFolderURL(folderName: "Codegen")
    .apollo.childFolderURL(folderName: "ApolloCLI")

let targetURL = sourceRootURL
    .apollo.childFolderURL(folderName: "Sources")
    .apollo.childFolderURL(folderName: "neeva-ios-support")

var codegenOptions = ApolloCodegenOptions(targetRootURL: targetURL)

do {
    try ApolloCodegen.run(from: targetURL,
                          with: cliFolderURL,
                          options: codegenOptions)
} catch {
    print(error)
    exit(1)
}
