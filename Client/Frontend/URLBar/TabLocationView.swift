// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

enum TabLocationViewUX {
    static let height: CGFloat = 42
}

struct TabLocationButtonStyle: ButtonStyle {
    struct Body: View {
        let configuration: Configuration

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            configuration.label
                .brightness(configuration.isPressed ? (
                    colorScheme == .dark ? 0.2 : -0.3
                ) : 0)
        }
    }
    func makeBody(configuration: Configuration) -> Body {
        Body(configuration: configuration)
    }
}

struct TabLocationView: View {
    enum Status {
        case insecure
        case secure
        case search
        case untrusted
        case connectionError

        var icon: Symbol? {
            switch self {
            case .insecure: return nil
            case .secure: return Symbol(.lockFill)
            case .search: return Symbol(.magnifyingglass)
            case .untrusted: return Symbol(.lockSlashFill)
            case .connectionError: return Symbol(.exclamationmarkTriangleFill)
            }
        }
    }

    init(text: String, status: Status, onTap: @escaping () -> ()) {
        self.text = text
        self.status = status
        self.onTap = onTap
    }

    let text: String
    let status: Status
    let onTap: () -> ()

    var body: some View {
        Button(action: onTap) {
            Capsule()
                .fill(Color.systemFill)
        }
        .buttonStyle(TabLocationButtonStyle())
        .overlay(TabLocationAligner {
            Label {
                Text(text).truncationMode(.head)
            } icon: {
                if let icon = status.icon {
                    icon
                }
            }.frame(height: TabLocationViewUX.height)
        } leading: {
            TabLocationBarButton(label: Image("tracking-protection").renderingMode(.template)) {}
        } trailing: {
            TabLocationBarButton(label: Symbol(.arrowClockwise)) {}
            TabLocationBarButton(label: Symbol(.squareAndArrowUp)) {}

        })
        .frame(height: TabLocationViewUX.height)
    }
}

struct URLBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(text: "vviii.verylong.subdomain.neeva.com", status: .insecure) {}
            TabLocationView(text: "neeva.com", status: .secure) {}
            TabLocationView(text: "a long search query with words", status: .search) {}
            TabLocationView(text: "you-broke-it.badssl.com", status: .untrusted) {}
            TabLocationView(text: "something.badssl.com", status: .connectionError) {}
        }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
