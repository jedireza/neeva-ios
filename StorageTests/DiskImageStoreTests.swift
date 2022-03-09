/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit
import XCTest

@testable import Storage

class DiskImageStoreTests: XCTestCase {
    var files: FileAccessor!
    var store: DiskImageStore!

    override func setUp() {
        files = MockFiles()
        store = DiskImageStore(files: files, namespace: "DiskImageStoreTests", quality: 1)

        store.updateAll([])
    }

    func testStore() {
        // Avoid image comparison and use size of the image for equality
        let redImage = makeImageWithColor(UIColor.red, size: CGSize(width: 100, height: 100))
        let blueImage = makeImageWithColor(UIColor.blue, size: CGSize(width: 17, height: 17))

        var entries: [DiskImageStore.Entry] = [
            .init(key: "blue", image: blueImage),
            .init(key: "red", image: redImage),
        ]

        entries.forEach {
            XCTAssertNil(getImage($0.key), "\($0.key) key is nil")
        }

        store.updateAll(entries)

        entries.forEach {
            XCTAssertEqual(getImage($0.key)!.size.width, $0.image.size.width, "Images are equal")
        }

        // Confirm that entries no longer specified get removed.
        entries.removeLast(1)
        store.updateAll(entries)
        XCTAssertNotNil(getImage("blue"), "Blue image still exists")
        XCTAssertNil(getImage("red"), "Red image cleared")
    }

    private func makeImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func getImage(_ key: String) -> UIImage? {
        let expectation = self.expectation(description: "Get succeeded")
        var image: UIImage?
        store.get(key) {
            image = $0
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        return image
    }
}
