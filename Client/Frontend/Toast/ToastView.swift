// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI

protocol ToastViewDelegate: AnyObject {
    func dismiss()
    func draggingUpdated()
    func draggingEnded(dismissing: Bool)
}

private enum ToastViewUX {
    static let height: CGFloat = 53
    static let threshold: CGFloat = 15
}

struct ToastView: View {
    /// used by ToastViewModel to dismiss view
    weak var viewDelegate: ToastViewDelegate?

    // how long the Toast is shown
    var displayTime = 4.5

    // content
    let text: String

    // button will hide if text is nil
    var buttonText: String?
    var buttonAction: (() -> ())?

    var showProgressView = false

    @State var offset: CGFloat = 0

    var opacity: CGFloat {
        let delta = abs(offset) - ToastViewUX.threshold
        return delta > 0 ? 1 - delta / (ToastViewUX.threshold * 3) : 1
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged {
                self.offset = $0.translation.height
                viewDelegate?.draggingUpdated()
            }
            .onEnded {
                var dismissing = false
                if abs($0.predictedEndTranslation.height) > ToastViewUX.height * 1.5 {
                    self.offset = $0.predictedEndTranslation.height
                    dismissing = true
                } else if abs($0.translation.height) > ToastViewUX.height {
                    dismissing = true
                } else {
                    self.offset = 0
                }

                viewDelegate?.draggingEnded(dismissing: dismissing)
            }
    }

    var body: some View {
        VStack {
            Spacer()

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color(SimpleToastUX.ToastDefaultColor))
                    .frame(minHeight: ToastViewUX.height)

                HStack(spacing: 16) {
                    if showProgressView {
                        ToastProgressView()
                    }

                    Text(text)
                        .lineLimit(3)
                        .font(.system(size: 16, weight: .medium))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical)

                    if let buttonText = buttonText {
                        Spacer()

                        Button(action: {
                            if let buttonAction = buttonAction {
                                buttonAction()
                            }

                            viewDelegate?.dismiss()
                        }, label: {
                            Text(buttonText)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.neeva.ui.aqua)

                        })
                    }
                }.padding(.horizontal, 16).colorScheme(.dark)
            }.frame(height: 53).padding(.horizontal)
        }
        .offset(y: offset)
        .gesture(drag)
        .opacity(Double(opacity))
        .animation(.interactiveSpring(), value: offset)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(text: "Tab Closed", buttonText: "Restore")
    }
}
