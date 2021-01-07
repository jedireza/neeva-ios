//
//  EditThumbnailView.swift
//  
//
//  Created by Jed Fox on 1/5/21.
//

import SwiftUI

struct EditThumbnailView: View {
    @Binding var selectedThumbnail: String
    @StateObject var controller: EntityThumbnailController
    init(spaceId: String, entityId: String, selectedThumbnail: Binding<String>) {
        _controller = .init(wrappedValue: EntityThumbnailController(spaceId: spaceId, entityId: entityId))
        _selectedThumbnail = selectedThumbnail
    }
    var body: some View {
        if let images = controller.data {
            if images.isEmpty {
                HStack {
                    Spacer()
                    Text("No thumbnails found.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(images) { image in
                            if let thumbnail = image.thumbnail,
                               let dataURIBody = thumbnail.dataURIBody,
                               let uiImage = UIImage(data: dataURIBody) {
                                Button {
                                    selectedThumbnail = thumbnail
                                } label: {
                                    ThumbnailImage(image: uiImage, isSelected: thumbnail == selectedThumbnail)
                                }
                            }
                        }
                    }.padding()
                }.padding(.horizontal, -20)
            }
        } else if let error = controller.error {
            Text(error.localizedDescription)
        } else {
            LoadingView("Loading thumbnails…", mini: true)
                .frame(height: 85)
                .padding()
        }
    }
}

struct ThumbnailImage: View {
    let image: UIImage
    let isSelected: Bool
    var body: some View {
        let thumbnailImage = Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 95, height: 85)
            .cornerRadius(6)
        if isSelected {
            thumbnailImage
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 5)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .font(Font.title.bold())
                        .frame(width: 20, height: 20)
                        .padding(7)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                )
        } else {
            thumbnailImage
        }
    }
}

struct EditThumbnailView_Previews: PreviewProvider {
    struct TestView: View {
        @State var selectedThumbnail = ""
        var body: some View {
            Form {
                EditThumbnailView(spaceId: "SkksIM_iAclak16nHYfcqAY8IwxsasTD1pU1XqUe", entityId: "0x1d170643a0684be5", selectedThumbnail: .constant(testSpace.thumbnail!))
            }
        }
    }
    static var previews: some View {
        HStack {
            let image = UIImage(data: testSpace.thumbnail!.dataURIBody!)!
            ThumbnailImage(image: image, isSelected: false)
            ThumbnailImage(image: image, isSelected: true)
        }
        TestView()
    }
}
