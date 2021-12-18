// Copyright Neeva. All rights reserved.

import Foundation
import SnapKit
import UIKit

class CryptoWalletController: UIViewController {
    private lazy var panel = UIView()

    var onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupPanel() {
        panel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupView() {
        view.addSubview(panel)
        panel.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
        addSubSwiftUIView(CryptoWalletView(onDismiss: onDismiss), to: panel)
        setupPanel()
    }

}
