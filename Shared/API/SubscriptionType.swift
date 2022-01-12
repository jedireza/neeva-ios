// Copyright Neeva. All rights reserved.

import SwiftUI

extension SubscriptionType {
    public var displayName: LocalizedStringKey {
        switch self {
        case .basic: return "Free Basic"
        case .premium, .lifetime: return "Premium"
        default: return "\(Image(systemSymbol: .exclamationmarkTriangleFill)) Membership Unknown"
        }
    }

    public var color: Color {
        switch self {
        case .basic: return .brand.polar
        case .premium, .lifetime: return .brand.variant.offwhite
        default: return .secondarySystemFill
        }
    }
}
