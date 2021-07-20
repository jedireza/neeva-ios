// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import SFSafeSymbols
import Shared
import Defaults
import Combine

struct NeevaMenuPanelSpec: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, alignment: .leading)
            .padding(NeevaUIConstants.menuInnerPadding)
            .background(Color.secondaryGroupedBackground)
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
    @Published var preventTrackersForCurrentPage: Bool {
        didSet {
            guard let domain = selectedTab?.currentURL()?.host else {
                return
            }

            if (preventTrackersForCurrentPage) {
                TrackingPreventionConfig.disallowTrackersFor(domain)
            } else {
                TrackingPreventionConfig.allowTrackersFor(domain)
            }

            selectedTab?.contentBlocker?.notifiedTabSetupRequired()
            selectedTab?.reload()
            refreshStats()
        }
    }

    private var selectedTab: Tab? = nil
    private var subscriptions: Set<AnyCancellable> = []

    var trackers: [TrackingEntity] {
        didSet {
            onDataUpdated()
        }
    }

    init(tabManager: TabManager) {
        self.selectedTab = tabManager.selectedTab
        self.preventTrackersForCurrentPage =
            !Defaults[.unblockedDomains].contains(selectedTab?.currentURL()?.host ?? "")
        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(stats: selectedTab?.contentBlocker?.stats)
        self.numTrackers = trackingData.numTrackers
        self.numDomains = trackingData.numDomains
        self.trackers = trackingData.trackingEntities
        tabManager.selectedTabPublisher.assign(to: \.selectedTab, on: self).store(in: &subscriptions)
        onDataUpdated()
    }

    // For usage with static data and testing only
    init(testingData: TrackingData) {
        self.preventTrackersForCurrentPage = true
        self.numTrackers = testingData.numTrackers
        self.numDomains = testingData.numDomains
        self.trackers = testingData.trackingEntities
        onDataUpdated()
    }

    func refreshStats() {
        guard let tab = selectedTab else {
            return
        }

        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(
            stats: tab.contentBlocker?.stats)
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
    @EnvironmentObject var viewModel: TrackingStatsViewModel

    @State private var isShowingPopup = false

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.preventTrackersForCurrentPage {
                HStack {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers)
                    TrackingMenuFirstRowElement(label: "Domains", num: viewModel.numDomains)
                }
                if !viewModel.hallOfShameDomains.isEmpty {
                    HallOfShameView(hallOfShameDomains: viewModel.hallOfShameDomains)
                }
            }
            TrackingMenuProtectionRowButton(preventTrackers: $viewModel.preventTrackersForCurrentPage)

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
                    TrackingMenuSettingsView(domain: "example.com")
                }
            }
        }
        .padding(NeevaUIConstants.menuOuterPadding)
        .background(Color.groupedBackground).fixedSize(horizontal: true, vertical: true)
        .onAppear {
            self.viewModel.refreshStats()
        }
    }
}
