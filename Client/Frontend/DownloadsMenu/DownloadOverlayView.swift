// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI
import Shared

struct DownloadMenuView: View {
    let fileName: String
    let fileURL: String
    let fileSize: String?
    
    let onDownload: () -> ()
    let onDismiss: () -> ()

    private let cellHeight = CGFloat(52)
    private struct Cell<Content: View>: View {
        let content: () -> Content
        var body: some View {
            content()
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(12)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .withFont(.bodyLarge)
                    .truncationMode(.middle)
                    .foregroundColor(.primary)

                Text(fileURL)
                    .withFont(.labelMedium)
                    .truncationMode(.head)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .center, spacing: 12) {
                Cell {
                    Button(action: { onDownload() }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text(fileSize != nil ? "Download (\(fileSize!))" : "Download")
                            Spacer()
                        }.frame(height: cellHeight)
                    }
                }

                Cell {
                    Button(action: { onDismiss() }) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Cancel").withFont(.labelLarge)
                            Spacer()
                        }.frame(height: cellHeight)
                    }

                }
            }
            .foregroundColor(.ui.adaptive.blue)
            .buttonStyle(TableCellButtonStyle())
        }.padding()
    }
}

struct DownloadMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadMenuView(fileName: "markus-spiske-jsqrSfrtjB80-unsplash.jpg", fileURL: "www.unsplash.com", fileSize: "2.2 MB", onDownload: {}, onDismiss: {})
    }
}
