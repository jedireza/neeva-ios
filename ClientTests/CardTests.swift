// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI
import ViewInspector
import XCTest

@testable import Client

class CardTests: XCTestCase {

    var profile: TabManagerMockProfile!
    var manager: TabManager!
    var delegate: MockTabManagerDelegate!
    var groupManager: TabGroupManager!
    var tabCardModel: TabCardModel!
    var tabGroupCardModel: TabGroupCardModel!

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
                XCTAssertTrue(
                    self.tabGroupCardModel.allDetails.first?.thumbnail
                        is ThumbnailGroupView<TabGroupCardDetails>)

                XCTAssertEqual(self.tabGroupCardModel.allDetails.first?.allDetails.count, 2)
                XCTAssertEqual(
                    self.tabGroupCardModel.allDetails.first?.allDetails.first?.id, tab1.tabUUID)
                XCTAssertEqual(
                    self.tabGroupCardModel.allDetails.first?.allDetails.last?.id, tab2.tabUUID)

                let thumbnail =
                    self.tabGroupCardModel.allDetails.first!.thumbnail
                    as! ThumbnailGroupView<TabGroupCardDetails>
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
}
