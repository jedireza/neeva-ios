// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AdServices
import Defaults
import Foundation
import Shared
import StoreKit
import SwiftyJSON

private enum AttributionTokenErrorType: String {
    case olderIOSRequest
    case jsonParsingError
    case requestError
    case emptyToken
}

/// Reports conversion events to SKAdNetwork. Avoids reporting the same event
/// more than once, so it is safe to call `log(event:)` multiple times for the
/// same event.
class ConversionLogger {
    enum Event: Int {
        case launchedApp = 0
        case visitedDefaultBrowserSettings = 10
        case handledNavigationAsDefaultBrowser = 20
    }

    static func log(event: Event) {
        guard event.rawValue > Defaults[.lastReportedConversionEvent] else {
            return
        }
        Defaults[.lastReportedConversionEvent] = event.rawValue
        if event.rawValue == 0 {
            SKAdNetwork.registerAppForAdNetworkAttribution()
            logAttributionData()
        } else {
            SKAdNetwork.updateConversionValue(event.rawValue)
        }
    }

    private static func logAttributionData() {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                // Kick-off a POST request to resolve the token.
                guard let url = URL(string: "https://api-adservices.apple.com/api/v1/") else {
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = Data(token.utf8)
                request.setValue("text/plain", forHTTPHeaderField: "Content-Type")

                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil else {
                        Logger.browser.error(
                            "Failed to resolve attributionToken: \(error!.localizedDescription)")
                        logAttributionDataError(
                            errorType: AttributionTokenErrorType.requestError,
                            error: error
                        )
                        return
                    }
                    if let data = data, let json = try? JSON(data: data) {
                        DispatchQueue.main.async {
                            var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
                            for (key, value) in json {
                                attributes.append(
                                    ClientLogCounterAttribute(
                                        key: "AT-\(key)", value: value.stringValue))
                            }
                            ClientLogger.shared.logCounter(
                                .ResolvedAttributionToken, attributes: attributes)
                        }
                    } else {
                        logAttributionDataError(
                            errorType: AttributionTokenErrorType.jsonParsingError,
                            error: nil
                        )
                    }
                }.resume()
            } else {
                logAttributionDataError(
                    errorType: AttributionTokenErrorType.emptyToken,
                    error: nil
                )
            }
        } else {
            logAttributionDataError(
                errorType: AttributionTokenErrorType.olderIOSRequest,
                error: nil
            )
        }
    }

    private static func logAttributionDataError(
        errorType: AttributionTokenErrorType, error: Error?
    ) {
        var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.AttributionTokenErrorType,
                value: errorType.rawValue
            )
        )
        if let message = error?.localizedDescription {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.AttributionTokenErrorMessage,
                    value: message
                )
            )
        }
        ClientLogger.shared.logCounter(
            .ResolvedAttributionTokenError,
            attributes: attributes
        )
    }
}
