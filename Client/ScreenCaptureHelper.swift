// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared

class ScreenCaptureHelper {
    class var defaultHelper: ScreenCaptureHelper {
        struct Singleton {
            static let instance = ScreenCaptureHelper()
        }
        return Singleton.instance
    }

    private static let deliminater = "##;::"

    private var isUserSignedIn: Bool {
        NeevaUserInfo.shared.hasLoginCookie()
    }

    private var currentQuery = CurrentValueSubject<String?, Never>(nil)
    private var capturedQueries = Set<String>()
    private var querySubscription: AnyCancellable?

    private var subscriptions = Set<AnyCancellable>()

    init() {
        currentQuery
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                guard self.capturedQueries.count <= 10 else {
                    return
                }
                self.capturedQueries.insert(query)
            }
            .store(in: &subscriptions)
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capturedDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }

    @objc private func userDidTakeScreenshot(_ notification: Notification) {
        var attributes = [EnvironmentHelper.shared.getSessionUUID()]
        if self.isUserSignedIn {
            attributes.append(
                ClientLogCounterAttribute(
                    key: "query",
                    value: self.currentQuery.value
                )
            )
        }
        ClientLogger.shared.logCounter(
            .didTakeScreenshot,
            attributes: attributes
        )
    }

    @objc private func capturedDidChange(_ notification: Notification) {
        if UIScreen.main.isCaptured {
            ClientLogger.shared.logCounter(
                .screenCaptureStarted,
                attributes: [EnvironmentHelper.shared.getSessionUUID()]
            )
            self.capturedQueries.removeAll(keepingCapacity: true)
            if let query = currentQuery.value {
                capturedQueries.insert(query)
            }
        } else {
            var attributes = [EnvironmentHelper.shared.getSessionUUID()]
            if self.isUserSignedIn {
                attributes.append(
                    ClientLogCounterAttribute(
                        key: "queries",
                        value: self.capturedQueries.joined(separator: Self.deliminater)
                    )
                )
            }
            ClientLogger.shared.logCounter(
                .screenCaptureFinished,
                attributes: attributes
            )
        }
    }

    func subscribeToTabUpdates(from publisher: AnyPublisher<Tab?, Never>) {
        publisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab in
                guard let self = self, !tab.isIncognito else { return }
                self.querySubscription?.cancel()
                self.currentQuery.send(nil)
                self.querySubscription = tab.$url
                    .compactMap { $0 }
                    .filter { NeevaConstants.isNeevaSearchResultPage($0) }
                    .compactMap { url -> String? in
                        SearchEngine.current.queryForSearchURL(url)
                    }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] query in
                        self?.currentQuery.send(query)
                    }
            }
            .store(in: &subscriptions)
    }
}
