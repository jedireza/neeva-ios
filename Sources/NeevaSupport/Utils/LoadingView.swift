import SwiftUI

struct LoadingView: View {
    let label: Text
    init(_ label: String) {
        self.label = Text(label)
    }
    init(_ label: Text) {
        self.label = label
    }
    var body: some View {
        VStack {
            ActivityIndicator(style: .large)
            label
                .font(Font.titleTwo.bold())
                .padding(.top)
                .multilineTextAlignment(.center)
        }.padding(40)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView("Adding to space…")
        LoadingView(String(repeating: "A really long title, ", count: 10))
        LoadingView(String(repeating: "A really long title, ", count: 10))
            .previewDevice("iPod touch (7th generation)")
    }
}
