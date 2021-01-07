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

    @State fileprivate var modal: Modal? = nil
    @State var isDeleting = false

    var body: some View {
        let spaceEntity = entity.spaceEntity!
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
                    Menu {
                        if spaceAcl >= .edit {
                            Button(action: { modal = .edit }) {
                                Text("Edit")
                                Image(systemName: "pencil")
                            }
                        }
                        Button(action: { modal = .addToSpace }) {
                            Text("Add to another Space")
                            Image(systemName: "plus")
                        }
                        if spaceAcl >= .edit {
                            Button(action: { isDeleting = true }) {
                                Text("Remove")
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .imageScale(.large)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 5)
                            .contentShape(Rectangle())
                    }.accentColor(.blue)
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
                    isPresented: .init(get: { self.modal == .edit }, set: { self.modal = $0 ? .edit : nil }),
                    onUpdate: onUpdate
                )
            case .addToSpace:
                AddToSpaceView(
                    title: entity.spaceEntity!.title!,
                    description: entity.spaceEntity!.snippet,
                    url: URL(string: entity.spaceEntity!.url!)!,
                    onDismiss: { ids in
                        self.modal = nil
                        if let ids = ids, ids.space == self.spaceId {
                            onUpdate(nil)
                            // TODO: make this work properly — the new entity is not actually added to the end of the list
                            // onUpdate { newSpace in
                            //     var newEntity = self.entity
                            //     newEntity.metadata?.docId = ids.entity
                            //     newSpace.entities?.append(newEntity)
                            // }
                        }
                    }
                ).buttonStyle(DefaultButtonStyle())
            }
        }).actionSheet(isPresented: $isDeleting, content: {
            ActionSheet(
                title: Text("Are you sure that you want to remove this item from your space?"),
                buttons: [
                    .destructive(Text("Remove")) {
                        BatchDeleteSpaceResultMutation(space: spaceId, results: [entity.id]).perform { result in
                            guard case .success(let data) = result, data.batchDeleteSpaceResult else { return }
                            onUpdate { newSpace in
                                newSpace.entities!.removeAll(where: { $0.id == entity.id })
                            }
                        }
                    },
                    .cancel()
                ])
        })
    }
}

struct SpaceEntityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpaceEntityView(entity: testSpace.entities![1], spaceId: "", spaceAcl: .owner, onUpdate: { _ in })
            SpaceEntityView(entity: testSpace.entities![2], spaceId: "", spaceAcl: .edit, onUpdate: { _ in })
            SpaceEntityView(entity: testSpace.entities![3], spaceId: "", spaceAcl: nil, onUpdate: { _ in })
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
