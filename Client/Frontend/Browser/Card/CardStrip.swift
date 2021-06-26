// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared
import Combine

struct CardStrip<Model: CardModel>: View {
    typealias Details = Model.Details
    @ObservedObject var model: Model
    let onLongPress: (String) -> ()

    var body: some View {
            LazyHStack(spacing: 32) {
                ForEach(model.allDetails.indices, id: \.self) { index in
                    let details = model.allDetails[index]
                    Card<Details>(details: details, config: .carousel).onLongPressGesture {
                        onLongPress(model.allDetails[index].id)
                    }
                }
            }.padding().frame(height: 275)
    }
}

struct TabsAndSpacesView: View {
    @ObservedObject var tabModel: TabCardModel
    @ObservedObject var spaceModel: SpaceCardModel
    @ObservedObject var sitesModel: SiteCardModel
    @State var showingSpaces: Bool = false
    @State var showingSites: Bool = false

    var body: some View {
        ZStack {
            if showingSites {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                showingSites.toggle()
                            }
                        }, label: {
                            Symbol(.xmark, size: 24, weight: .semibold, label: "Close Sites View")
                                .foregroundColor(
                                    Color(UIColor.label))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .animation(.spring())
                        }).frame(width: CardUX.CardSize / 2, height: CardUX.CardSize)
                            .background(Color(UIColor.Browser.background))
                            .cornerRadius(CardUX.CornerRadius)
                            .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
                        CardStrip(model: self.sitesModel, onLongPress: {_ in })
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: {
                            spaceModel.onDataUpdated()
                            withAnimation {
                                showingSpaces.toggle()
                            }
                        }, label: {
                            Symbol(.bookmark, size: 24, weight: .semibold, label: "Show Spaces")
                                .foregroundColor(
                                    Color(showingSpaces ? UIColor.Browser.background : UIColor.label))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .background(Color(showingSpaces ?
                                                    UIColor.label : UIColor.Browser.background))
                                .clipShape(Circle()).animation(.spring())
                        }).frame(width: CardUX.CardSize / 2, height: CardUX.CardSize)
                        .background(Color(UIColor.Browser.background))
                        .cornerRadius(CardUX.CornerRadius)
                        .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
                        if showingSpaces {
                            CardStrip(model: spaceModel, onLongPress: {_ in })
                        }
                        CardStrip(model: tabModel, onLongPress: {id in
                            showingSites = true
                            let urls: [URL] = (tabModel.manager.get(for: id)?.backList?.map {
                                $0.url
                            })!
                            self.sitesModel.refresh(urls: urls)
                        })
                    }
                }
            }
        }.onAppear {
            tabModel.onDataUpdated()
        }.frame(maxWidth:.infinity)
        .background(LinearGradient(gradient: Gradient(colors:
                                                        [.clear, .label.opacity(0.3), .clear]),
                                                        startPoint: .top, endPoint: .bottom))
    }
}
