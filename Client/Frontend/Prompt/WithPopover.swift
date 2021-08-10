//  Need this wrapper because Popover from SwiftUI will display as an
//  overlay sheet on mobile, it will only display the arrow popover style
//  on larger screen(tablet)
//  https://stackoverflow.com/questions/58834809/change-popover-size-in-swiftui/60077135#60077135
//
//
import Foundation
import SwiftUI

struct WithPopover<Content: View, PopoverContent: View>: View {

    @Binding var showPopover: Bool
    var popoverSize: CGSize? = nil
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    let staticColorMode: Bool?

    var body: some View {
        content()
            .if(showPopover) { view in
                view
                    .background(
                        Wrapper(
                            showPopover: $showPopover, popoverSize: popoverSize,
                            popoverContent: popoverContent, staticColorMode: staticColorMode
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
            }
    }

    struct Wrapper<PopoverContent: View>: UIViewControllerRepresentable {

        @Binding var showPopover: Bool
        let popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        let staticColorMode: Bool?

        func makeUIViewController(
            context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>
        ) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                popoverContent: popoverContent,
                staticColorMode: self.staticColorMode
            ) {
                self.showPopover = false
            }
        }

        func updateUIViewController(
            _ uiViewController: WrapperViewController<PopoverContent>,
            context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>
        ) {
            uiViewController.updateSize(popoverSize)

            if showPopover {
                uiViewController.showPopover()
            } else {
                uiViewController.hidePopover()
            }
        }
    }

    class WrapperViewController<PopoverContent: View>: UIViewController,
        UIPopoverPresentationControllerDelegate
    {

        var popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void
        let staticColorMode: Bool?
        var popoverVC: UIViewController?

        required init?(coder: NSCoder) { fatalError("") }
        init(
            popoverSize: CGSize?,
            popoverContent: @escaping () -> PopoverContent,
            staticColorMode: Bool? = false,
            onDismiss: @escaping () -> Void
        ) {
            self.popoverSize = popoverSize
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            self.staticColorMode = staticColorMode
            super.init(nibName: nil, bundle: nil)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.view.backgroundColor =
                self.staticColorMode!
                ? UIColor.Tour.Background.lightVariant : UIColor.Tour.Background
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.delegate = self
            }
            popoverVC = vc

            // when in landscape mode, menu is shown using PopOverNeevaMenuViewController
            // delay tour popover being shown to prevent view is not in the window hierarchy complain
            let delay = BrowserViewController.foregroundBVC().chromeModel.inlineToolbar ? 0.5 : 0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.present(vc, animated: true, completion: nil)
            }
        }

        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }

        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }

        func adaptivePresentationStyle(for controller: UIPresentationController)
            -> UIModalPresentationStyle
        {
            return .none
        }
    }
}
