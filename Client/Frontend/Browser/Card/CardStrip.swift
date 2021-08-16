// Copyright Neeva. All rights reserved.

import Combine
import Shared
import Storage
import SwiftUI

/// This file contains models and views for the iPad card strip, which is not enabled by default.

private struct CardStrip<Model: CardModel>: View {
    @ObservedObject var model: Model
    let onLongPress: (String) -> Void

    var body: some View {
        LazyHStack(spacing: 32) {
            ForEach(model.allDetails.indices, id: \.self) { index in
                let details = model.allDetails[index]
                Card(details: details)
                    .aspectRatio(1, contentMode: .fit)
                    .environment(\.selectionCompletion) {}
                    .environment(\.cardSize, CardUX.DefaultCardSize)
                    .onLongPressGesture {
                        onLongPress(model.allDetails[index].id)
                    }
            }
        }.padding().frame(height: 275)
    }
}

private struct CardStripButtonSpec: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(width: CardUX.DefaultCardSize / 2, height: 124)
            .background(Color.DefaultBackground)
            .clipShape(Capsule())
            .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
    }
}

class CardStripModel: ObservableObject {
    var onToggleVisible: ((Bool) -> Void)!
    var isVisible: Bool = false

    func toggleVisible() {
        isVisible.toggle()
        onToggleVisible(isVisible)
    }
}

struct CardStripView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var sitesModel: SiteCardModel
    @EnvironmentObject var cardStripModel: CardStripModel
    @State var showingSpaces: Bool = false
    @State var showingSites: Bool = false

    var body: some View {
        ZStack {
            if showingSites {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        DismissButton {
                            withAnimation {
                                showingSites.toggle()
                            }
                        }.modifier(CardStripButtonSpec())
                        CardStrip(model: self.sitesModel, onLongPress: { _ in })
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        VStack(spacing: 12) {
                            ToggleSpacesButton(showingSpaces: $showingSpaces)
                            DismissButton {
                                cardStripModel.toggleVisible()
                            }
                        }.modifier(CardStripButtonSpec())
                            .onTapGesture {
                                cardStripModel.toggleVisible()
                            }
                        if showingSpaces {
                            CardStrip(model: spaceModel, onLongPress: { _ in })
                        }
                        CardStrip(
                            model: tabModel,
                            onLongPress: { id in
                                showingSites = true
                                let urls: [URL] =
                                    (tabModel.manager.get(for: id)?.backList?.map {
                                        $0.url
                                    })!
                                self.sitesModel.refresh(urls: urls)
                            })
                    }
                }
            }
        }.onAppear {
            tabModel.onDataUpdated()
        }.frame(maxWidth: .infinity)
    }
}

private struct ToggleSpacesButton: View {
    @EnvironmentObject var spaceModel: SpaceCardModel
    @Binding var showingSpaces: Bool

    var body: some View {
        Button {
            spaceModel.onDataUpdated()
            withAnimation {
                showingSpaces.toggle()
            }
        } label: {
            Symbol(.bookmark, size: 18, weight: .semibold, label: "Show Spaces")
                .foregroundColor(
                    Color(showingSpaces ? UIColor.DefaultBackground : UIColor.label)
                )
                .aspectRatio(contentMode: .fit)
                .tapTargetFrame()
                .background(Color(showingSpaces ? UIColor.label : UIColor.DefaultBackground))
                .clipShape(Circle()).animation(.spring())
        }
    }
}

private struct DismissButton: View {
    var onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            Symbol(.xmark, size: 18, weight: .semibold, label: "Dismiss View")
                .foregroundColor(
                    Color(UIColor.label)
                )
                .aspectRatio(contentMode: .fit)
                .tapTargetFrame()
                .animation(.spring())
        }
    }
}
