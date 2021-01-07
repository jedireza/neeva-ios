import Foundation

public struct NeevaConstants {
    public static let appHost = "alpha.neeva.co"
    public static let loginKeychainKey = "neevaHttpdLogin-\(appHost)"

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
