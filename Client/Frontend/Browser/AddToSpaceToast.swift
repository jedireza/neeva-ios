// Copyright Neeva. All rights reserved.

import SnapKit
import SwiftUI
import Shared

extension AddToSpaceRequest {
    var isDone: Bool {
        return state == .failed || state == .savedToSpace
    }
}

struct AddToSpaceToastView: View {
    @StateObject var request: AddToSpaceRequest

    var onOpenSpace: (String) -> ()
    var onDismiss: () -> ()

    var labelText: String {
        let spaceName = request.targetSpaceName ?? "## Unknown ##"
        switch request.state {
        case .initial:
            assert(false)  // Should not be reached
            return ""
        case .creatingSpace, .savingToSpace:
            return "Saving..."
        case .savedToSpace:
            return "Saved to \"\(spaceName)\""
        case .deletingFromSpace:
            return "Deleting..."
        case .deletedFromSpace:
            return "Deleted from \"\(spaceName)\""
        case .failed:
            return "Failed to save to \"\(spaceName)\""
        }
    }

    var showOpenSpaceButton: Bool {
        switch request.state {
        case .savedToSpace, .deletedFromSpace:
            return true
        default:
            return false
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(labelText)
                .padding(.leading, 16)
                .font(.system(size: 14))

            Spacer()

            if showOpenSpaceButton {
                Button {
                    onOpenSpace(request.targetSpaceID!)
                } label: {
                    Text("Open Space")
                        .foregroundColor(Color.neeva.ui.aqua)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.trailing, 16)
            }
            // TODO: Add spinner in the saving case
        }
        .colorScheme(.dark)
        .navigationBarHidden(true)
        .frame(height: 72)
        .background(Color.neeva.DarkElevated)
        .cornerRadius(15)
        .padding([.leading, .trailing], 8)
        .padding(.bottom, 14)
        .onChange(of: request.state) { newValue in
            if request.isDone {
                self.onDismiss()
            }
        }
    }
}

class AddToSpaceToast: Toast {
    private var request: AddToSpaceRequest
    private var onOpenSpace: (String) -> ()
    private var dismissalInterval: DispatchTimeInterval?

    init(request: AddToSpaceRequest, onOpenSpace: @escaping (String) -> ()) {
        self.request = request
        self.onOpenSpace = onOpenSpace
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showToast(viewController: UIViewController? = nil, delay: DispatchTimeInterval = SimpleToastUX.ToastDelayBefore, duration: DispatchTimeInterval? = SimpleToastUX.ToastDismissAfter, makeConstraints: @escaping (SnapKit.ConstraintMaker) -> Swift.Void) {
        let view = AddToSpaceToastView(request: self.request, onOpenSpace: { self.onOpenSpace($0) }, onDismiss: { self.dismissSoon() })
        viewController!.addSubSwiftUIView(view, to: self)

        // Force duration to nil to prevent auto-dismissal. Capture the duration
        // it would use so we can use that later when we want to allow the toast
        // to finally auto-dismiss (b/c we finished saving or an error occured).
        self.dismissalInterval = duration
        let durationToUse = self.request.isDone ? duration : nil
        super.showToast(viewController: viewController, delay: delay, duration: durationToUse, makeConstraints: makeConstraints)
    }

    private func dismissSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.dismissalInterval!) {
            self.dismiss(false)
        }
    }
}
