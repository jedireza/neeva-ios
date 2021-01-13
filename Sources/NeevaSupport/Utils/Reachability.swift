//
//  Reachability.swift
//  
//
//  Created by Jed Fox on 1/12/21.
//

import Foundation
import Reachability

public class NetworkReachability: ObservableObject {
    public static var shared = NetworkReachability()
    @Published public var isOnline: Bool?
    @Published public var connection: Reachability.Connection?

    private let reachability = try! Reachability()

    init() {
        reachability.whenReachable = { reachability in
            self.isOnline = true
            self.connection = reachability.connection
        }
        reachability.whenUnreachable = { _ in
            self.isOnline = false
            self.connection = nil
        }
        try! reachability.startNotifier()
    }

    deinit {
        reachability.stopNotifier()
    }
}
