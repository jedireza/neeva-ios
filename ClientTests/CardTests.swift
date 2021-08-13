// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI
import ViewInspector
import XCTest

@testable import Client

extension CardGrid: Inspectable {}
extension CardsContainer: Inspectable {}
extension TabCardsView: Inspectable {}
extension SpaceCardsView: Inspectable {}
extension FittedCard: Inspectable {}
extension Card: Inspectable {}
extension ThumbnailGroupView: Inspectable {}

private func assertCast<T>(_ value: Any, to _: T.Type) -> T {
    XCTAssertTrue(value is T)
    return value as! T
}

class CardTests: XCTestCase {

    var profile: TabManagerMockProfile!
    var manager: TabManager!
    var delegate: MockTabManagerDelegate!
    var groupManager: TabGroupManager!
    var tabCardModel: TabCardModel!
    var tabGroupCardModel: TabGroupCardModel!
    var spaceCardModel: SpaceCardModel!

    fileprivate let spyDidSelectedTabChange =
        "tabManager(_:didSelectedTabChange:previous:isRestoring:)"
    fileprivate let spyRestoredTabs = "tabManagerDidRestoreTabs(_:)"
    fileprivate let spyAddTab = "tabManager(_:didAddTab:isRestoring:)"

    override func setUp() {
        super.setUp()

        profile = TabManagerMockProfile()
        manager = TabManager(profile: profile, imageStore: nil)
        delegate = MockTabManagerDelegate()
        groupManager = TabGroupManager(tabManager: manager)
        tabCardModel = TabCardModel(manager: manager, groupManager: groupManager)
        tabGroupCardModel = TabGroupCardModel(manager: groupManager)

        SpaceStore.shared = .createMock([.stackOverflow, .savedForLater, .shared, .public])
        spaceCardModel = SpaceCardModel()
    }

    override func tearDown() {
        profile._shutdown()
        manager.removeDelegate(delegate)
        manager.removeAll()

        super.tearDown()
    }

    func testTabDetails() throws {
        let tab1 = manager.addTab()

        let _ = MethodSpy(functionName: spyAddTab) { _ in
            XCTAssertEqual(self.tabCardModel.allDetails.count, 1)
            XCTAssertEqual(self.tabCardModel.allDetails.first?.id, tab1.tabUUID)
            XCTAssertFalse(self.tabCardModel.allDetails.first?.isSelected ?? true)
            self.manager.selectTab(tab1)
            XCTAssertTrue(self.tabCardModel.allDetails.first?.isSelected ?? false)

            let tab2 = self.manager.addTab()
            let _ = MethodSpy(functionName: self.spyAddTab) { _ in
                XCTAssertEqual(self.tabCardModel.allDetails.count, 2)
                XCTAssertEqual(self.tabCardModel.allDetails.last?.id, tab2.tabUUID)
                XCTAssertFalse(self.tabCardModel.allDetails.last?.isSelected ?? true)

                XCTAssertTrue(self.groupManager.tabGroups.isEmpty)
                XCTAssertTrue(self.tabGroupCardModel.allDetails.isEmpty)
            }
        }
    }

    func testTabGroupDetails() throws {
        let tab1 = manager.addTab()

        let _ = MethodSpy(functionName: spyAddTab) { _ in
            XCTAssertEqual(self.tabCardModel.allDetails.count, 1)
            XCTAssertEqual(self.tabCardModel.allDetails.first?.id, tab1.tabUUID)
            XCTAssertFalse(self.tabCardModel.allDetails.first?.isSelected ?? true)
            self.manager.selectTab(tab1)
            XCTAssertTrue(self.tabCardModel.allDetails.first?.isSelected ?? false)

            let tab2 = self.manager.addTab(afterTab: tab1)
            let _ = MethodSpy(functionName: self.spyAddTab) { _ in
                XCTAssertEqual(self.tabCardModel.allDetails.count, 2)
                XCTAssertEqual(self.tabCardModel.allDetails.last?.id, tab2.tabUUID)

                XCTAssertTrue(self.tabCardModel.allDetailsWithExclusionList.isEmpty)

                XCTAssertEqual(self.groupManager.tabGroups.count, 1)
                XCTAssertEqual(self.tabGroupCardModel.allDetails.count, 1)
                XCTAssertEqual(self.tabGroupCardModel.allDetails.first?.id, tab1.rootUUID)

                XCTAssertEqual(self.tabGroupCardModel.allDetails.first?.allDetails.count, 2)
                XCTAssertEqual(
                    self.tabGroupCardModel.allDetails.first?.allDetails.first?.id, tab1.tabUUID)
                XCTAssertEqual(
                    self.tabGroupCardModel.allDetails.first?.allDetails.last?.id, tab2.tabUUID)

                let thumbnail = assertCast(
                    self.tabGroupCardModel.allDetails.first!.thumbnail,
                    to: ThumbnailGroupView<TabGroupCardDetails>.self)
                XCTAssertEqual(thumbnail.numItems, 2)

                let tab3 = self.manager.addTab(afterTab: tab1)
                let _ = MethodSpy(functionName: self.spyAddTab) { _ in
                    XCTAssertEqual(self.groupManager.tabGroups.count, 1)
                    XCTAssertEqual(self.tabGroupCardModel.allDetails.count, 1)

                    XCTAssertEqual(self.tabGroupCardModel.allDetails.first?.allDetails.count, 3)
                    XCTAssertEqual(
                        self.tabGroupCardModel.allDetails.first?.allDetails.last?.id, tab3.tabUUID)
                    XCTAssertEqual(thumbnail.numItems, 3)
                }
            }
        }
    }

    func testSpaceDetails() throws {
        XCTAssertEqual(SpaceStore.shared.getAll().count, 4)
        SpaceStore.shared.getAll().first!.contentData = [
            SpaceEntityData(
                url: .aboutBlank, title: nil, snippet: nil,
                thumbnail: SpaceThumbnails.githubThumbnail),
            SpaceEntityData(
                url: .aboutBlank, title: nil, snippet: nil,
                thumbnail: SpaceThumbnails.stackOverflowThumbnail),
        ]
        SpaceStore.shared.getAll().last!.contentData = [
            SpaceEntityData(
                url: .aboutBlank, title: nil, snippet: nil,
                thumbnail: SpaceThumbnails.githubThumbnail)
        ]
        let firstCard = SpaceCardDetails(space: SpaceStore.shared.getAll().first!)
        XCTAssertEqual(firstCard.id, Space.stackOverflow.id.id)
        XCTAssertEqual(firstCard.allDetails.count, 2)
        let firstThumbnail = try firstCard.thumbnail.inspect().vStack().view(
            ThumbnailGroupView<SpaceCardDetails>.self, 0
        ).actualView()
        XCTAssertNotNil(firstThumbnail)
        XCTAssertEqual(firstThumbnail.numItems, 2)
        // The model should not update until the SpaceStore refreshes
        XCTAssertEqual(spaceCardModel.allDetails.count, 0)
        // Send a dummy event to simulate a store refresh
        SpaceStore.shared.objectWillChange.send()
        XCTAssertEqual(spaceCardModel.allDetails.count, 4)

        let lastCard = spaceCardModel.allDetails.last!
        XCTAssertEqual(lastCard.id, Space.public.id.id)
        XCTAssertEqual(lastCard.allDetails.count, 1)
        let lastThumbnail = try lastCard.thumbnail.inspect().vStack().view(
            ThumbnailGroupView<SpaceCardDetails>.self, 0
        ).actualView()
        XCTAssertNotNil(lastThumbnail)
        XCTAssertEqual(lastThumbnail.numItems, 1)
    }

    func testCardGrid() throws {
        manager.addTab()
        manager.addTab()
        manager.addTab()
        waitForCondition(condition: { manager.tabs.count == 3 })
        // Make sure all the models are up to date
        manager.objectWillChange.send()

        let model = GridModel()
        let cardGrid = CardGrid().environmentObject(tabCardModel)
            .environmentObject(tabGroupCardModel).environmentObject(model)

        let cardContainer = try cardGrid.inspect().find(CardsContainer.self)
        XCTAssertNotNil(cardContainer)
        let tabCardsView = try cardGrid.inspect().find(TabCardsView.self)
        XCTAssertNotNil(tabCardsView)

        let tabCards = tabCardsView.findAll(FittedCard<TabCardDetails>.self)
        XCTAssertEqual(tabCards.count, 3)

        manager.addTab()
        manager.addTab()
        waitForCondition(condition: { manager.tabs.count == 5 })
        XCTAssertEqual(manager.tabs.count, 5)
        // Make sure all the models are up to date
        manager.objectWillChange.send()
        XCTAssertEqual(tabCardsView.findAll(FittedCard<TabCardDetails>.self).count, 5)
    }

    func testCardGridWithSpaces() throws {
        manager.addTab()
        manager.addTab()
        manager.addTab()
        waitForCondition(condition: { manager.tabs.count == 3 })
        // Make sure all the models are up to date
        manager.objectWillChange.send()

        let model = GridModel()
        SpaceStore.shared.objectWillChange.send()

        let cardContainer = CardsContainer(
            switcherState: .constant(.spaces),
            columns: Array(repeating: GridItem(.fixed(100), spacing: 20), count: 2)
        ).environmentObject(tabCardModel).environmentObject(spaceCardModel)
            .environmentObject(tabGroupCardModel).environmentObject(model)
            .environmentObject(tabGroupCardModel)

        let spaceCardsView = try cardContainer.inspect().find(SpaceCardsView.self)
        XCTAssertNotNil(spaceCardsView)

        let spaceCards = spaceCardsView.findAll(FittedCard<SpaceCardDetails>.self)
        XCTAssertEqual(spaceCards.count, 4)
    }
}
