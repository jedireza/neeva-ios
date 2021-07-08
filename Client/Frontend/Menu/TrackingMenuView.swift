// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import SFSafeSymbols
import Shared
import Defaults

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

class TrackingStatsViewModel: ObservableObject {
    @Published var numTrackers = 0
    @Published var numDomains = 0
    @Published var hallOfShameDomains = [Dictionary<TrackingEntity, Int>.Element]()

    var trackers: [TrackingEntity] {
        didSet {
            onDataUpdated()
        }
    }

    init(trackingData: TrackingData) {
        self.numTrackers = trackingData.numTrackers
        self.numDomains = trackingData.numDomains
        self.trackers = trackingData.trackingEntities
        onDataUpdated()
    }

    func onDataUpdated() {
        let trackerDict = trackers.reduce(into: [:]) { $0[$1] = ($0[$1] ?? 0) + 1 }
            .sorted(by: {$0.1 > $1.1})

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
            Text(label).withFont(.headingMedium).foregroundColor(.secondaryLabel)
            Text("\(num)").withFont(.displayMedium)
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
            Text("\(hallOfShameDomain.value)").withFont(.displayMedium)
        }.accessibilityLabel(
            "\(hallOfShameDomain.value) trackers blocked from \(hallOfShameDomain.key.rawValue)")
        .accessibilityIdentifier("TrackingMenu.HallOfShameElement")
    }
}

struct HallOfShameView: View {
    let hallOfShameDomains: [Dictionary<TrackingEntity, Int>.Element]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hall of Shame").withFont(.headingMedium).foregroundColor(.secondaryLabel)
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
    @StateObject var viewModel = TrackingStatsViewModel(
        trackingData: TrackingEntity.getTrackingDataForCurrentTab()
    )

    @Default(.contentBlockingEnabled) private var isTrackingProtectionEnabled
    @State private var isShowingPopup = false

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

            TrackingMenuProtectionRowButton(isTrackingProtectionEnabled: $isTrackingProtectionEnabled)

            if FeatureFlag[.newTrackingProtectionSettings] {
                Button(action: { isShowingPopup = true }) {
                    HStack {
                        Text("Advanced Privacy Settings").withFont(.bodyLarge)
                        Spacer()
                        Symbol(.shieldLefthalfFill)
                    }
                }
                .buttonStyle(TableCellButtonStyle(padding: -NeevaUIConstants.menuInnerPadding))
                .applyNeevaMenuPanelSpec()
                .sheet(isPresented: $isShowingPopup) {
                    TrackingMenuSettingsView(host: "example.com")
                }
            }
        }
        .padding(NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.PopupMenu.background)).fixedSize(horizontal: true, vertical: true)
    }
}

struct TrackingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuView(viewModel: TrackingStatsViewModel(trackingData: TrackingData(numTrackers: 10, numDomains: 5, trackingEntities: [.Amazon, .Amazon, .Adobe, .Adobe, .Criteo, .Google])))
    }
}
