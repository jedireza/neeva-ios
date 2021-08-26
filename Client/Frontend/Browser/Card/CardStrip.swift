// Copyright Neeva. All rights reserved.

import Combine
import Shared
import Storage
import SwiftUI

/// This file contains models and views for the iPad card strip, which is not enabled by default.

private struct CardStrip<Model: CardModel>: View {
    @ObservedObject var model: Model
    @State var isHover: Bool = false
    let onLongPress: (String) -> Void

    var alwaysShowThumbnail: Bool

    var body: some View {
        LazyHStack(spacing: 12) {
            ForEach(model.allDetails.indices, id: \.self) { index in
                let details = model.allDetails[index]
                CompactCardContent(details: details, isHover: isHover, alwaysShowThumbnail: alwaysShowThumbnail)
                    .environment(\.selectionCompletion) {}
                    .environment(\.cardSize, CardUX.DefaultCardSize)
                    .onLongPressGesture {
                        onLongPress(model.allDetails[index].id)
                    }
            }
        }
        .padding(.vertical)
        .frame(height: alwaysShowThumbnail || isHover ? CardUX.CompactCardHeight + CardUX.CompactCardThumbnailHeight + 100 : CardUX.CompactCardHeight + 48)
        .onHover { isHover in
            withAnimation {
                self.isHover = isHover
            }
        }
    }
}

private struct CardStripButtonSpec: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 350, height: 100)
            .background(Color.DefaultBackground)
            .clipShape(Capsule())
            .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
    }
}

class CardStripModel: ObservableObject {
    @Published var isVisible: Bool = true

    let tabManager: TabManager

    func setVisible(to state: Bool) {
        withAnimation {
            isVisible = state
        }
    }

    func toggleVisible() {
        withAnimation {
            isVisible.toggle()
        }
    }

    func selectTabForDrag(distance: CGFloat) {
        let distance = abs(distance)
        let distanceToNextTab = 25
        let index = Int(distance / distanceToNextTab)
        let tabs = tabManager.isIncognito ? tabManager.privateTabs : tabManager.normalTabs

        if index > tabs.count - 1 {
            tabManager.select(tabs[tabs.count - 1])
        } else {
            tabManager.select(tabs[index])
        }
    }

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}

struct CardStripView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var sitesModel: SiteCardModel
    @EnvironmentObject var cardStripModel: CardStripModel

    @State var showingSpaces: Bool = false
    @State var showingSites: Bool = false
    @State var alwaysShowThumbnail: Bool = false

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
                        CardStrip(model: self.sitesModel, onLongPress: { _ in }, alwaysShowThumbnail: alwaysShowThumbnail)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            if cardStripModel.isVisible {
                                ToggleSpacesButton(showingSpaces: $showingSpaces)
                                NewTabButton(onNewTab: {
                                    let bvc = SceneDelegate.getBVC(with: tabModel.manager.scene)
                                    bvc.openLazyTab(openedFrom: .openTab(tabModel.manager.selectedTab))
                                })
                            }

                            DismissButton {
                                cardStripModel.toggleVisible()
                            }
                        }

                        Toggle("Always Show Thumbnail", isOn: $alwaysShowThumbnail)
                            .padding(.leading, 6)
                    }
                    .padding(.leading, 24)
                    .padding(.trailing, 32)
                    .modifier(CardStripButtonSpec())
                    .onTapGesture {
                        cardStripModel.toggleVisible()
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        if showingSpaces && spaceModel.allDetails.count > 0 {
                            CardStrip(model: spaceModel, onLongPress: { _ in }, alwaysShowThumbnail: alwaysShowThumbnail)
                                .environmentObject(cardStripModel)
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
                            }, alwaysShowThumbnail: alwaysShowThumbnail)
                            .environmentObject(cardStripModel)
                    }
                }
            }
        }.onAppear {
            tabModel.onDataUpdated()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
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

private struct NewTabButton: View {
    var onNewTab: () -> Void

    var body: some View {
        Button(action: onNewTab) {
            Symbol(.plusApp, size: 18, weight: .semibold, label: "New Tab")
                .foregroundColor(
                    Color(UIColor.label)
                )
                .aspectRatio(contentMode: .fit)
                .tapTargetFrame()
                .animation(.spring())
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
