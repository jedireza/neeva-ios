// Copyright Neeva. All rights reserved.

import SwiftUI
import SFSafeSymbols

enum ToastProgressStatus: String {
    case inProgress = ""
    case success = "checkmark"
    case failed = "xmark"

    var icon: SFSymbol? {
        switch self {
        case .success:
            return .checkmark
        case .failed:
            return .xmark
        default:
            return nil
        }
    }
}

class ToastProgressViewModel: ObservableObject {
    @Published var status: ToastProgressStatus = .inProgress
    @Published var download: Download?
}

struct ToastProgressView: View {
    var backgroundColor: Color = Color(SimpleToastUX.ToastDefaultColor)
    var stateDidChange: ((ToastProgressStatus) -> ())?

    @EnvironmentObject var toastProgressViewModel: ToastProgressViewModel

    var body: some View {
        ZStack(alignment: .center) {
            if let icon = toastProgressViewModel.status.icon {
                Circle()
                    .foregroundColor(.white)

                Image(systemSymbol: icon)
                    .foregroundColor(backgroundColor)
                    .padding(8)
            } else {
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 2))
            }
        }.frame(width: 24, height: 24).onChange(of: toastProgressViewModel.status) { _ in
            if let stateDidChange = stateDidChange {
                stateDidChange(toastProgressViewModel.status)
            }
        }
    }
}

struct ToastProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ToastProgressView()
            .preferredColorScheme(.dark)
    }
}
