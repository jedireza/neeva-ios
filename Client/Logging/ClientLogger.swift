// Copyright Neeva. All rights reserved.

import Foundation
import Apollo
import Shared

enum ClientLoggerStatus {
    case enabled
    case disabled
}

public class ClientLogger {
    public var env: ClientLogEnvironment
    private let status: ClientLoggerStatus

    public static let shared = ClientLogger()

    public init() {
        self.env = ClientLogEnvironment.init(rawValue: "Prod")!
        // disable client logging until we have a plan for privacy control
        self.status = .enabled
    }

    public func logCounter(_ path: LogConfig.Interaction, attributes: [ClientLogCounterAttribute] = []) {
        if self.status != ClientLoggerStatus.enabled {
            return
        }

        if !LogConfig.featureFlagEnabled(for: LogConfig.category(for: path)) {
            return
        }

        let clientLogBase = ClientLogBase(id: "co.neeva.app.ios.browser", version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, environment: self.env)
        let clientLogCounter = ClientLogCounter(path: path.rawValue, attributes: attributes)
        let clientLog = ClientLog(counter: clientLogCounter)
        LogMutation(
            input: ClientLogInput(
                base: clientLogBase,
                log: [clientLog]
            )
        ).perform { result in
            switch result {
            case .failure(let error):
                print("LogMutation Error: \(error)")
            case .success:
                break
            }
        }

    }
}
