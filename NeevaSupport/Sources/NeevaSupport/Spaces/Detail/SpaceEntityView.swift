//
//  SpaceEntityView.swift
//  
//
//  Created by Jed Fox on 12/21/20.
//

import SwiftUI
import RemoteImage

fileprivate struct Metrics {
    static let imageWidth: CGFloat = 95
    static let imageHeight: CGFloat = 80
    static let cornerRadius: CGFloat = 6
}

fileprivate enum Modal: String, Identifiable {
    case edit
    case addToSpace
    var id: String { rawValue }
}

struct SpaceEntityView: View {
    let entity: SpaceController.Space.Entity
    let spaceId: String
    let spaceAcl: SpaceACLLevel?
    let onUpdate: Updater<SpaceController.Space>
    let onDelete: () -> ()

    @State fileprivate var modal: Modal? = nil
    @State var isDeleting = false

    var body: some View {
        let spaceEntity = entity.spaceEntity!

        let actions = [
            .edit(condition: spaceAcl >= .edit) { modal = .edit },
            Action("Add to another Space", icon: "plus", condition: !(spaceEntity.url?.isEmpty ?? true)) { modal = .addToSpace },
            .delete(condition: spaceAcl >= .edit, handler: onDelete)
        ]

        HStack(alignment: .top) {
            if let data = spaceEntity.thumbnail?.dataURIBody,
               let thumbnail = UIImage(data: data) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Metrics.imageWidth, height: Metrics.imageHeight, alignment: .center)
                    .cornerRadius(Metrics.cornerRadius)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    Text(spaceEntity.title!)
                        .font(.title3)
                        .fontWeight(spaceEntity.url?.isEmpty ?? true ? .semibold : .regular) 
                    Spacer()
                    actions.menu
                }
                if let url = spaceEntity.url, !url.isEmpty {
                    Text(spaceEntity.url!)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .lineLimit(1)
                    if let snippet = spaceEntity.snippet, !snippet.isEmpty {
                        Text(spaceEntity.snippet ?? "")
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }
            }.lineLimit(2)
        }.sheet(item: $modal, content: { modal in
            switch modal {
            case .edit:
                EditEntityView(
                    for: entity,
                    inSpace: spaceId,
                    onDismiss: { self.modal = nil },
                    onUpdate: onUpdate
                )
            case .addToSpace:
                AddToSpaceView(
                    request: AddToSpaceRequest(
                        title: entity.spaceEntity!.title!,
                        description: entity.spaceEntity!.snippet,
                        url: URL(string: entity.spaceEntity!.url!)!),
                    onDismiss: {
                        self.modal = nil
                        // TODO: Hook this up properly and show progress for the request.
                    }
                ).buttonStyle(DefaultButtonStyle())
            }
        })
        .accessibilityElement(children: .combine)
        .accessibilityActions(actions.filter { $0?.name != "Remove" })
    }
}

struct SpaceEntityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpaceEntityView(entity: testSpace.entities![1], spaceId: "", spaceAcl: .owner, onUpdate: { _ in }, onDelete: {})
            SpaceEntityView(entity: testSpace.entities![2], spaceId: "", spaceAcl: .edit, onUpdate: { _ in }, onDelete: {})
            SpaceEntityView(entity: testSpace.entities![3], spaceId: "", spaceAcl: nil, onUpdate: { _ in }, onDelete: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
