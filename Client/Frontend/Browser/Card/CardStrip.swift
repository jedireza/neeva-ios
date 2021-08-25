// Copyright Neeva. All rights reserved.

import Combine
import Shared
import Storage
import SwiftUI

/// This file contains models and views for the iPad card strip, which is not enabled by default.

private struct CardStrip<Model: CardModel>: View {
    @ObservedObject var model: Model
    let onLongPress: (String) -> Void

    @EnvironmentObject var cardStripModel: CardStripModel

    var body: some View {
        LazyHStack(spacing: 12) {
            ForEach(model.allDetails.indices, id: \.self) { index in
                let details = model.allDetails[index]
                CompactCardContent(details: details)
                    .environment(\.selectionCompletion) {}
                    .environment(\.cardSize, CardUX.DefaultCardSize)
                    .onLongPressGesture {
                        onLongPress(model.allDetails[index].id)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { gesture in
                                print(gesture.translation.width)
                                cardStripModel.selectTabForDrag(distance: gesture.translation.width)
                            }
                    )
            }
        }.padding(.vertical)
    }
}

private struct CardStripButtonSpec: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(width: 160, height: CardUX.DefaultCardSize / 3)
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
                VStack(alignment: .leading) {
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
                    .modifier(CardStripButtonSpec())
                    .padding(.top)
                    .onTapGesture {
                        cardStripModel.toggleVisible()
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        if showingSpaces && spaceModel.allDetails.count > 0 {
                            CardStrip(model: spaceModel, onLongPress: { _ in })
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
                            })
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
