import SwiftUI
import NeevaSupport

struct FeedbackView: View {
    @State var presenting = false
    @State var allowShareQuery = false

    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                SendFeedbackView.Button(canShareResults: allowShareQuery)
                Toggle("Enable “share query” toggle", isOn: $allowShareQuery)
                VStack {
                    Text("Note").bold()
                    Text("This screen submits actual feedback reports to Neeva")
                }.multilineTextAlignment(.center)
            }
            .font(.title3)
            .padding(.horizontal, 60)
            .navigationTitle("Send Feedback")
        }
    }
}

class FeedbackViewController: UIHostingController<FeedbackView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: FeedbackView())
    }
}
