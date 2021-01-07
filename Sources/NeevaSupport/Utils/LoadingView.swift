import SwiftUI

public struct LoadingView: View {
    let label: Text
    let mini: Bool
    public init(_ label: String, mini: Bool = false) {
        self.label = Text(label)
        self.mini = mini
    }
    public init(_ label: Text, mini: Bool = false) {
        self.label = label
        self.mini = mini
    }
    public var body: some View {
        if mini {
            HStack {
                ActivityIndicator(style: .medium)
                label
                    .padding(.leading)
                    .padding(.vertical, 5)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }
        } else {
            VStack {
                ActivityIndicator(style: .large)
                label
                    .font(Font.title2.bold())
                    .padding(.top)
                    .multilineTextAlignment(.center)
            }.padding(40)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section {
                LoadingView("Adding to space…", mini: true)
            }
            Section {
                LoadingView(String(repeating: "A really long title, ", count: 10), mini: true)
            }
        }
        LoadingView("Adding to space…")
        LoadingView(String(repeating: "A really long title, ", count: 10))
        LoadingView(String(repeating: "A really long title, ", count: 10))
            .previewDevice("iPod touch (7th generation)")
    }
}
