import SwiftUI
import NeevaSupport

struct FeedbackView: View {
    @State var presenting = false
    @State var allowShareQuery = false
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                Button(action: { presenting = true }) {
                    Label("Send Feedback", systemImage: "bubble.left.fill")
                        .font(Font.title.bold())
                }
                Toggle("Enable “share query” toggle", isOn: $allowShareQuery)
                VStack {
                    Text("Note").bold()
                    Text("This screen submits actual feedback reports to Neeva")
                }.multilineTextAlignment(.center)
            }
            .font(.title3)
            .padding(.horizontal, 60)
            .sheet(isPresented: $presenting, content: {
                SendFeedbackView(canShareResults: allowShareQuery)
            })
            .navigationTitle("Send Feedback")
        }
    }
}

class FeedbackViewController: UIHostingController<FeedbackView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: FeedbackView())
    }
}
