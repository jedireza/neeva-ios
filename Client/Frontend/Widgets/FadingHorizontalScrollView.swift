// Copyright © Neeva. All rights reserved.

import SwiftUI

struct FadingHorizontalScrollView<Content: View>: UIViewRepresentable {
    let content: (CGSize) -> Content

    init(@ViewBuilder content: @escaping (CGSize) -> Content) {
        self.content = content
    }

    typealias UIViewType = FadingHorizontalScrollView_UIView<Content>

    func makeUIView(context: Context) -> UIViewType {
        UIViewType(rootView: content)
    }
    func updateUIView(_ view: UIViewType, context: Context) {
        view.rootView = content
    }
}

struct FadingHorizontalScrollView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            FadingHorizontalScrollView { size in
                HStack {
                    Color.yellow.frame(width: 50, height: 50)
                        .overlay(Text("\(size.width)\n\(size.height)"))
                    ForEach(0..<10) { _ in
                        Color.yellow.frame(width: 50, height: 50)
                    }
                }.fixedSize()
            }
            Spacer()
        }
    }
}

class FadingHorizontalScrollView_UIView<Content: View>: UIView, UIScrollViewDelegate {
    let scrollView = UIScrollView()
    let hostingController: UIHostingController<Content>

    let leadingGradient = CAGradientLayer()
    let trailingGradient = CAGradientLayer()

    var rootView: (CGSize) -> Content {
        didSet {
            hostingController.rootView = rootView(scrollView.visibleSize)
            scrollViewDidScroll(scrollView)
        }
    }

    init(rootView: @escaping (CGSize) -> Content) {
        self.hostingController = UIHostingController(rootView: rootView(.zero))
        self.rootView = rootView
        super.init(frame: .zero)

//        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.isOpaque = false
        self.backgroundColor = .clear

        scrollView.isOpaque = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)

        hostingController.view.backgroundColor = .clear
        hostingController.view.isOpaque = false

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(hostingController.view)
        scrollView.delegate = self
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        leadingGradient.colors = [
            UIColor.HomePanel.topSitesBackground.withAlphaComponent(0).cgColor,
            UIColor.HomePanel.topSitesBackground.cgColor,
        ]
        trailingGradient.colors = leadingGradient.colors

        leadingGradient.transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
        trailingGradient.transform = CATransform3DMakeRotation(-(.pi / 2), 0, 0, 1)

        leadingGradient.frame.size.width = 64
        trailingGradient.frame.size.width = 64

        leadingGradient.zPosition = 2
        trailingGradient.zPosition = 2

        leadingGradient.opacity = 0

        if UIDevice.current.userInterfaceIdiom != .pad {
            self.layer.addSublayer(leadingGradient)
            self.layer.addSublayer(trailingGradient)
        }
    }

    override func layoutSubviews() {
        hostingController.rootView = rootView(scrollView.bounds.size)
        super.layoutSubviews()
        hostingController.rootView = rootView(scrollView.bounds.size)
        scrollViewDidScroll(scrollView)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        bounds.size.height = hostingController.view.intrinsicContentSize.height
        trailingGradient.frame.origin.x = bounds.width - trailingGradient.frame.width
        leadingGradient.frame.size.height = bounds.height
        trailingGradient.frame.size.height = bounds.height
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        leadingGradient.opacity = Float(max(0, min(1, scrollView.contentOffset.x / 10)))
        trailingGradient.opacity = Float(max(0, min(1, (scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.bounds.width)) / 10)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
