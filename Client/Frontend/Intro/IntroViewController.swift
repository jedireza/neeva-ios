/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import AuthenticationServices
import Foundation
import Shared
import SnapKit
import UIKit

enum FirstRunButtonActions {
    case signin
    case signupWithApple(Bool?, URL?)
    case signupWithOther
    case skipToBrowser
}

class IntroViewController: UIViewController,
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{

    private lazy var welcomeCard = UIView()
    private var marketingEmailOptOut: Bool = true

    // Closure delegate
    var didFinishClosure: ((FirstRunButtonActions) -> Void)?

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
        // Make sure all actions are run on the main thread to prevent runtime errors
        DispatchQueue.main.async {
            switch option {
            case FirstRunButtonActions.signupWithApple(let marketingEmailOptOut, _):
                ClientLogger.shared.logCounter(
                    .FirstRunSignupWithApple, attributes: [ClientLogCounterAttribute]())
                self.marketingEmailOptOut = marketingEmailOptOut ?? false
                self.doSignupWithApple()
            case FirstRunButtonActions.signin:
                ClientLogger.shared.logCounter(
                    .FirstRunSignin, attributes: [ClientLogCounterAttribute]())
                self.didFinishClosure?(.signin)
            case .signupWithOther:
                ClientLogger.shared.logCounter(
                    .FirstRunOtherSignUpOptions, attributes: [ClientLogCounterAttribute]())
                self.didFinishClosure?(.signupWithOther)
            case FirstRunButtonActions.skipToBrowser:
                ClientLogger.shared.logCounter(
                    .FirstRunSkipToBrowser, attributes: [ClientLogCounterAttribute]())
                self.didFinishClosure?(.skipToBrowser)
            }
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

    private func doSignupWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // redirect and create account
            let token = appleIDCredential.identityToken

            if token != nil {
                if let authStr = String(data: token!, encoding: .utf8) {
                    let authURL = NeevaConstants.appleAuthURL(
                        serverAuthCode: authStr,
                        marketingEmailOptOut: self.marketingEmailOptOut,
                        signup: true)
                    self.didFinishClosure?(.signupWithApple(nil, authURL))
                }
            }
            break
        default:
            break
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Logger.browser.error("Sign up with Apple failed: \(error)")
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
