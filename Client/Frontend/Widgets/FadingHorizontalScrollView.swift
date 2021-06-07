// Copyright © Neeva. All rights reserved.

import SwiftUI

/// This is a custom wrapper for `UIScrollView`, primarily used in `NeevaHome` to display suggested sites.
/// It adds two gradient overlays over the leading and trailing edges of the scroll view that show the user more content
/// is visible without obscuring items at the edges of the scroll view’s content. UIKit is currently necessary to support
/// controlling the visibility of the gradients on scroll and because views laid on top of a SwiftUI `ScrollView` always
/// prevent touches from passing through to scroll the `ScrollView`.
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

    // CAGradientLayer is used here to render the gradients.
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

        applyColors()

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
            // calculate proper gradient opacity after a short delay to give
            // SwiftUI time to mount the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.scrollViewDidScroll(self.scrollView)
            }
        }
    }

    // resize this view to match the height of the hosting controller, and update the SwiftUI view
    // with information about the parent view’s size.
    override func layoutSubviews() {
        hostingController.rootView = rootView(scrollView.bounds.size)
        super.layoutSubviews()
        hostingController.rootView = rootView(scrollView.bounds.size)
        bounds.size.height = hostingController.view.intrinsicContentSize.height
        scrollViewDidScroll(scrollView)
    }

    // adjust the position and size of the gradient views
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        trailingGradient.frame.origin.x = bounds.width - trailingGradient.frame.width
        leadingGradient.frame.size.height = bounds.height
        trailingGradient.frame.size.height = bounds.height
    }

    /// adjust the opacity of the gradients based on current scroll position. Rapidly fade them in and out at the edges of the scrollable content area
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        leadingGradient.opacity = Float(max(0, min(1, scrollView.contentOffset.x / 10)))
        trailingGradient.opacity = Float(max(0, min(1, (scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.bounds.width)) / 10)))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyColors()
    }

    func applyColors() {
        leadingGradient.colors = [
            UIColor.HomePanel.topSitesBackground.withAlphaComponent(0).cgColor,
            UIColor.HomePanel.topSitesBackground.cgColor,
        ]
        trailingGradient.colors = leadingGradient.colors
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
