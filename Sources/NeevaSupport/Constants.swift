import Foundation
import Defaults

// will return default value if an invalid value is set
let neevaHostKey = Defaults.Key<String>("neevaHost", default: "alpha.neeva.co")

public struct NeevaConstants {
    public static var appHost: String {
        get { Defaults[neevaHostKey] }
        set { Defaults[neevaHostKey] = newValue }
    }
    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }

    public struct Header {
        public let name: String
        public let value: String
        private init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        // all Neeva requests
        public static let deviceType = Header("X-Neeva-Device-Type", "ios-browser")
    }
}
