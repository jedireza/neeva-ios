// Copyright Neeva. All rights reserved.

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
    @Published var hallOfShameDomains = [Dictionary<TrackingEntity, Int>.Element]()

    let settingsHandler: (() -> ())?
    var trackers: [TrackingEntity] {
        didSet {
            onDataUpdated()
        }
    }

    init(trackers: [TrackingEntity], settingsHandler: (() -> ())?) {
        self.trackers = trackers
        self.settingsHandler = settingsHandler
        onDataUpdated()
    }

    func onDataUpdated() {
        numTrackers = trackers.count
        let trackerDict = trackers.reduce(into: [:]) { $0[$1] = ($0[$1] ?? 0) + 1 }
            .sorted(by: {$0.1 > $1.1})
        numDomains = trackerDict.count

        guard !trackerDict.isEmpty else {
            hallOfShameDomains = [Dictionary<TrackingEntity, Int>.Element]()
            return
        }
        hallOfShameDomains = Array(trackerDict[0...min(trackerDict.count - 1, 2)])
    }
}

struct TrackingMenuFirstRowElement: View {
    let label: String
    let num: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.headline).foregroundColor(.secondaryLabel)
            Text("\(num)").font(.system(size: NeevaUIConstants.trackingMenuBlockedFontSize))
        }.applyNeevaMenuPanelSpec()
        .accessibilityLabel("\(num) \(label) blocked")
        .accessibilityIdentifier("TrackingMenu.TrackingMenuFirstRowElement")
    }
}

struct HallOfShameElement: View {
    let hallOfShameDomain: Dictionary<TrackingEntity, Int>.Element

    var body: some View {
        HStack(spacing: NeevaUIConstants.hallOfShameElementSpacing) {
            Image(hallOfShameDomain.key.rawValue).resizable().cornerRadius(5)
                .frame(width: NeevaUIConstants.hallOfShameElementFaviconSize,
                       height: NeevaUIConstants.hallOfShameElementFaviconSize)
            Text("\(hallOfShameDomain.value)").font(.system(size: NeevaUIConstants.menuFontSize))
        }.accessibilityLabel(
            "\(hallOfShameDomain.value) trackers blocked from \(hallOfShameDomain.key.rawValue)")
        .accessibilityIdentifier("TrackingMenu.HallOfShameElement")
    }
}

struct HallOfShameView: View {
    let hallOfShameDomains: [Dictionary<TrackingEntity, Int>.Element]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hall of Shame").font(.headline).foregroundColor(.secondaryLabel)
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
            if isTrackingProtectionEnabled {
                HStack {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers)
                    TrackingMenuFirstRowElement(label: "Domains", num: viewModel.numDomains)
                }
                if !viewModel.hallOfShameDomains.isEmpty {
                    HallOfShameView(hallOfShameDomains: viewModel.hallOfShameDomains)
                }
            }
            TrackingMenuProtectionRowButton(name:"Tracking Prevention",
                                            toggleAction: toggleTrackingProtection,
                                            isTrackingProtectionOn: isTrackingProtectionEnabled)
            if let _ = viewModel.settingsHandler {
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
        TrackingMenuView(isTrackingProtectionEnabled: true,
                         viewModel:TrackingStatsViewModel(trackers: [.Amazon, .Amazon, .Adobe, .Adobe,.Criteo,.Google], settingsHandler: {}))
    }
}
