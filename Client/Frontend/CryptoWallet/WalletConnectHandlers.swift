// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

protocol ResponseRelay {
    func send(_ response: Response)
    func askToSign(request: Request, message: String, sign: @escaping () -> String)
}

extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }
}

class PersonalSignHandler: RequestHandler {
    let relay: ResponseRelay
    let keyAccessor = WalletAccessor()

    init(relay: ResponseRelay) {
        self.relay = relay
    }

    func canHandle(request: Request) -> Bool {
        return request.method == "personal_sign"
    }

    func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: String.self, at: 1)

            // Match only the address not the checksum (OpenSea sends them always lowercased :( )
            guard address.lowercased() == keyAccessor.publicAddress.lowercased() else {
                relay.send(.reject(request))
                return
            }

            relay.askToSign(request: request, message: messageBytes) {
                return try! sign(message: messageBytes, using: self.keyAccessor.publicAddress)
            }
        } catch {
            relay.send(.invalid(request))
            return
        }
    }
}
