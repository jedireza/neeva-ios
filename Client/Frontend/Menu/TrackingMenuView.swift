//
//  TrackingMenuView.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Storage
import SFSafeSymbols
import Shared

struct NeevaMenuPanelSpec: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, alignment: .leading)
            .padding(NeevaUIConstants.menuInnerPadding)
            .background(Color(UIColor.PopupMenu.foreground))
            .cornerRadius(NeevaUIConstants.menuCornerDefault)
    }
}

extension View {
    func applyNeevaMenuPanelSpec() -> some View {
        self.modifier(NeevaMenuPanelSpec())
    }
}

class TrackingStatsViewModel:ObservableObject {
    @Published var numTrackers = 0
    @Published var numDomains = 0
    @Published var hallOfShameDomains = [Dictionary<URL, Int>.Element]()

    var trackers: [URL] {
        didSet {
            onDataUpdated()
        }
    }

    init(trackers: [URL]) {
        self.trackers = trackers
        onDataUpdated()
    }

    func onDataUpdated() {
        numTrackers = trackers.count
        let trackerDict = trackers.reduce(into: [:]) { $0[$1] = ($0[$1] ?? 0) + 1 }
            .sorted(by: {$0.1 > $1.1})
        numDomains = trackerDict.count

        guard !trackerDict.isEmpty else {
            hallOfShameDomains = [Dictionary<URL, Int>.Element]()
            return
        }
        hallOfShameDomains = Array(trackerDict[0...min(trackerDict.count - 1, 2)])
    }
}

struct TrackingMenuFirstRowElement: View {
    let label: String
    let num: Int
    let symbol: SFSymbol?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(label)").font(.system(size: NeevaUIConstants.menuFontSize)).foregroundColor(.secondary)
                if let symbol = symbol {
                    Symbol(symbol, size: 18, weight: .semibold)
                        .foregroundColor(.secondary)
                }
            }
            Text("\(num)").font(.system(size: NeevaUIConstants.trackingMenuBlockedFontSize))
        }.applyNeevaMenuPanelSpec()
        .accessibilityLabel("\(num) \(label) blocked")
        .accessibilityIdentifier("TrackingMenu.TrackingMenuFirstRowElement")
    }
}

struct HallOfShameElement: View {
    let hallOfShameDomain: Dictionary<URL, Int>.Element

    var body: some View {
        HStack(spacing: NeevaUIConstants.hallOfShameElementSpacing) {
            FaviconView(site: Site(url: hallOfShameDomain.key.absoluteString, title: "" )
                        , size: NeevaUIConstants.hallOfShameElementFaviconSize, bordered: true)
                .frame(width: NeevaUIConstants.hallOfShameElementFaviconSize,
                       height: NeevaUIConstants.hallOfShameElementFaviconSize)
            Text("\(hallOfShameDomain.value)").font(.system(size: NeevaUIConstants.menuFontSize))
        }.accessibilityLabel(
            "\(hallOfShameDomain.value) trackers blocked from \(hallOfShameDomain.key.baseDomain ?? "")")
        .accessibilityIdentifier("TrackingMenu.HallOfShameElement")
    }
}

struct HallOfShameView: View {
    let hallOfShameDomains: [Dictionary<URL, Int>.Element]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hall of Shame").font(.system(size: NeevaUIConstants.menuFontSize)).foregroundColor(.secondary)
            HStack(spacing: NeevaUIConstants.hallOfShameRowSpacing) {
                HallOfShameElement(hallOfShameDomain: hallOfShameDomains[0])
                if hallOfShameDomains.count >= 2 {
                    HallOfShameElement(hallOfShameDomain: hallOfShameDomains[1])
                }
                if hallOfShameDomains.count >= 3  {
                    HallOfShameElement(hallOfShameDomain: hallOfShameDomains[2])
                }
            }
        }.applyNeevaMenuPanelSpec()
    }
}

struct TrackingMenuView: View {
    var menuAction: ((TrackingMenuButtonActions) -> ())?
    var isTrackingProtectionEnabled: Bool
    @ObservedObject var viewModel: TrackingStatsViewModel

    init(menuAction: ((TrackingMenuButtonActions) -> ())? = nil,
         isTrackingProtectionEnabled: Bool, viewModel: TrackingStatsViewModel) {
        self.menuAction = menuAction
        self.isTrackingProtectionEnabled = isTrackingProtectionEnabled
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.trackers.isEmpty {
                HStack {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers, symbol: nil)
                    TrackingMenuFirstRowElement(label: "Domains", num: viewModel.numDomains, symbol: .personCropCircle)
                }
                HallOfShameView(hallOfShameDomains: viewModel.hallOfShameDomains)
            }
            TrackingMenuProtectionRowButton(name:"Block Tracking",
                                            toggleAction: toggleTrackingProtection,
                                            isTrackingProtectionOn: isTrackingProtectionEnabled)
            if !viewModel.trackers.isEmpty {
                HStack {
                    Text("Advanced Privacy Settings")
                        .foregroundColor(Color(UIColor.PopupMenu.textColor))
                        .font(.system(size: NeevaUIConstants.menuFontSize)).frame(maxWidth: .infinity, alignment: .leading)
                    Image("tracking-protection").renderingMode(.template)
                        .frame(width: 24, height: 24)
                }.applyNeevaMenuPanelSpec()
            }
        }.padding(NeevaUIConstants.menuOuterPadding)
            .background(Color(UIColor.PopupMenu.background)).fixedSize(horizontal: true, vertical: true)
    }

    func toggleTrackingProtection(){
        self.menuAction!(TrackingMenuButtonActions.tracking)
    }
}

struct TrackingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuView(isTrackingProtectionEnabled: true, viewModel: TrackingStatsViewModel(trackers: [URL]()))
    }
}
