/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SnapKit
import UIKit

enum FirstRunButtonActions {
    case signin
    case signup
    case skipToBrowser
}

class IntroViewController: UIViewController {
    private lazy var welcomeCard = UIView()

    // Closure delegate
    var didFinishClosure: ((IntroViewController) -> Void)?
    var visitHomePage: (() -> Void)?
    var visitSigninPage: (() -> Void)?

    // MARK: Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }

    // MARK: View setup
    private func initialViewSetup() {
        setupIntroView()
    }

    private func setupWelcomeCard() {
        // Constraints
        welcomeCard.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buttonAction(_ option: FirstRunButtonActions) {
        switch option {
        case FirstRunButtonActions.signin:
            ClientLogger.shared.logCounter(
                .FirstRunSignin, attributes: [ClientLogCounterAttribute]())
            self.didFinishClosure?(self)
            self.visitSigninPage?()
        case FirstRunButtonActions.signup:
            ClientLogger.shared.logCounter(
                .FirstRunSignUp, attributes: [ClientLogCounterAttribute]())
            self.didFinishClosure?(self)
            self.visitHomePage?()
        case FirstRunButtonActions.skipToBrowser:
            ClientLogger.shared.logCounter(
                .FirstRunSkipToBrowser, attributes: [ClientLogCounterAttribute]())
            self.didFinishClosure?(self)
        }
    }

    //onboarding intro view
    private func setupIntroView() {
        // Initialize
        view.addSubview(welcomeCard)
        welcomeCard.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
        addSubSwiftUIView(IntroFirstRunView(buttonAction: buttonAction), to: welcomeCard)
        setupWelcomeCard()
    }
}

// MARK: UIViewController setup
extension IntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}
