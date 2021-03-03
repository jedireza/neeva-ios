/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import SnapKit
import Shared
import Leanplum

class IntroViewController: UIViewController {
    // private var
    // Private views
    private lazy var welcomeCard: IntroScreenWelcomeView = {
        let welcomeCardView = IntroScreenWelcomeView()
        welcomeCardView.clipsToBounds = true
        return welcomeCardView
    }()
    // Closure delegate
    var didFinishClosure: ((IntroViewController) -> Void)?
    
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
        // Buton action closures
        // Next button action
        welcomeCard.nextClosure = {
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeCard.alpha = 0
            }) { _ in
                self.welcomeCard.isHidden = true
            }
        }
        // Close button action
        welcomeCard.closeClosure = {
            self.didFinishClosure?(self)
        }
    }
    
    //onboarding intro view
    private func setupIntroView() {
        // Initialize
        view.addSubview(welcomeCard)
        // Constraints
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
