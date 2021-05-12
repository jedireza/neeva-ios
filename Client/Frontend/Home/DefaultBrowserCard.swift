/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SnapKit
import Storage
import Shared
import NeevaSupport

class DefaultBrowserCard: UIView {
    public var dismissClosure: (() -> Void)?
    public var signinHandler: (() -> Void)?
    var isUserLoggedIn: Bool

    lazy var title: UILabel = {
        let title = UILabel()
        title.text = "Browse in peace,"
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        title.textColor = UIColor.theme.defaultBrowserCard.textColor
        return title
    }()
    lazy var title2: UILabel = {
        let title = UILabel()
        title.text = "always."
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        title.textColor = UIColor.theme.defaultBrowserCard.textColor
        return title
    }()

    lazy var actionButton: UIButton = {
        let button = UIButton()
        let neevaIcon = UIImage.templateImageNamed("neevaMenuIcon")
        button.setImage(neevaIcon, for: .normal)
        button.tintColor = UIColor.Neeva.Brand.White
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 80)
        button.setTitle("Sign in with Neeva", for: .normal)
        button.backgroundColor = UIColor.Neeva.Brand.Blue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        return button
    }()

    lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "nav-stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.imageView?.tintColor = UIColor.Neeva.UI.Gray70
        return closeButton
    }()
    lazy var background: UIView = {
        let background = UIView()
        background.backgroundColor = UIColor.theme.defaultBrowserCard.brandPistachio
        background.layer.cornerRadius = 12
        background.layer.masksToBounds = true
        return background
    }()
    private var topView = UIView()
    private var labelView = UIStackView()
    
    init(frame: CGRect, isUserLoggedIn: Bool) {
        self.isUserLoggedIn = isUserLoggedIn
        super.init(frame: frame)
        topView.addSubview(labelView)
        background.addSubview(actionButton)

        if (!NeevaUserInfo.shared.hasLoginCookie()) {
            background.backgroundColor = UIColor.theme.defaultBrowserCard.brandPolar
            title.text = "Get safer, richer, and"
            title2.text = "better search"
            closeButton.isHidden = true
        } else {
            actionButton.setImage(nil, for: .normal)
            actionButton.setTitle("Set Neeva as Default Browser", for: .normal)
        }

        background.addSubview(topView)
        background.addSubview(closeButton)
        labelView.axis = .vertical
        labelView.addArrangedSubview(title)
        labelView.addArrangedSubview(title2)

        addSubview(background)
        setupConstraints()
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        background.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.right.bottom.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(178)
        }
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(actionButton.snp.top)
            make.height.greaterThanOrEqualTo(64)
        }
        labelView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(25)
            make.width.lessThanOrEqualTo(292)
            make.bottom.equalTo(actionButton.snp.top).offset(-16)
            make.top.equalToSuperview().offset(30)
        }
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(-25)
            make.left.equalToSuperview().offset(25)
            make.height.equalTo(48)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(15)
        }
    }
    
    private func setupButtons() {
        closeButton.addTarget(self, action: #selector(dismissCard), for: .touchUpInside)

        if(!NeevaUserInfo.shared.hasLoginCookie()) {
            actionButton.addTarget(self, action: #selector(openLoginPage), for: .touchUpInside)
        } else {
            actionButton.addTarget(self, action: #selector(showOnboarding), for: .touchUpInside)
        }
    }
    
    @objc private func dismissCard() {
        ClientLogger.shared.logCounter(.CloseDefaultBrowserPromo, attributes: EnvironmentHelper.shared.getAttributes())
        self.dismissClosure?()
        UserDefaults.standard.set(true, forKey: "DidDismissDefaultBrowserCard")
    }
    
    @objc private func showOnboarding() {
        ClientLogger.shared.logCounter(.PromoDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
        BrowserViewController.foregroundBVC().presentDBOnboardingViewController(true)
        
        // Set default browser onboarding did show to true so it will not show again after user clicks this button
        UserDefaults.standard.set(true, forKey: PrefsKeys.KeyDidShowDefaultBrowserOnboarding)
    }

    @objc private func openLoginPage(){
        ClientLogger.shared.logCounter(.PromoSignin, attributes: EnvironmentHelper.shared.getAttributes())
        self.signinHandler?()
    }
    
    func applyTheme() {
        title.textColor = UIColor.theme.defaultBrowserCard.textColor
        backgroundColor = UIColor.theme.homePanel.topSitesBackground
    }
}
