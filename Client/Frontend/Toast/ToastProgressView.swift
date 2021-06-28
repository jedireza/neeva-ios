// Copyright Neeva. All rights reserved.

import SwiftUI
import SFSafeSymbols

enum ToastProgressStatus {
    case inProgress
    case success
    case failed

    var icon: SFSymbol{
        switch self {
        case .inProgress:
            return .circle
        case .success:
            return .checkmarkCircleFill
        case .failed:
            return .xmarkCircleFill
        }
    }
}

class ToastProgressViewModel: ObservableObject {
    @Published var status: ToastProgressStatus = .inProgress
}

struct ToastProgressView: View {
    var backgroundColor: Color = Color(SimpleToastUX.ToastDefaultColor)
    var stateDidChange: ((ToastProgressStatus) -> ())?

    @EnvironmentObject var toastProgressViewModel: ToastProgressViewModel

    var body: some View {
        ZStack(alignment: .center) {
            Image(systemSymbol: toastProgressViewModel.status.icon)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
        }.onChange(of: toastProgressViewModel.status) { _ in
            if let stateDidChange = stateDidChange {
                stateDidChange(toastProgressViewModel.status)
            }
        }
    }
}

struct ToastProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ToastProgressView()
            .environmentObject(ToastProgressViewModel())
            .preferredColorScheme(.dark)
    }
}
