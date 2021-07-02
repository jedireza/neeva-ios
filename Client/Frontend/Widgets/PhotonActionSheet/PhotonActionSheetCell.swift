/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage
import SnapKit
import Shared

// This file is the cells used for the PhotonActionSheet table view.

private enum PhotonActionSheetCellUX {
    static let StatusIconSize = 24
    static let SelectedOverlayColor = UIColor(white: 0.0, alpha: 0.25)
    static let CornerRadius: CGFloat = 3
}

class PhotonActionSheetCell: UITableViewCell {
    static let Padding: CGFloat = 16
    static let HorizontalPadding: CGFloat = 1
    static let VerticalPadding: CGFloat = 2
    static let IconSize = 16

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.minimumScaleFactor = 0.75 // Scale the font if we run out of space
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontSizeToFitWidth = true
        return label
    }

    private func createIconImageView() -> UIImageView {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.clipsToBounds = true
        icon.layer.cornerRadius = PhotonActionSheetCellUX.CornerRadius
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentCompressionResistancePriority(.required, for: .horizontal)
        return icon
    }

    lazy var titleLabel: UILabel = {
        let label = createLabel()
        label.numberOfLines = 4
        label.font = DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = createLabel()
        label.numberOfLines = 0
        label.font = DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS
        return label
    }()

    lazy var statusIcon: UIImageView = {
        return createIconImageView()
    }()

    lazy var disclosureLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var selectedOverlay: UIView = {
        let selectedOverlay = UIView()
        selectedOverlay.backgroundColor = PhotonActionSheetCellUX.SelectedOverlayColor
        selectedOverlay.isHidden = true
        return selectedOverlay
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = PhotonActionSheetCell.Padding
        stackView.alignment = .center
        stackView.axis = .horizontal
        return stackView
    }()

    override var isSelected: Bool {
        didSet {
            self.selectedOverlay.isHidden = !isSelected
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.statusIcon.image = nil
        disclosureLabel.removeFromSuperview()
        statusIcon.layer.cornerRadius = PhotonActionSheetCellUX.CornerRadius
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        isAccessibilityElement = true
        contentView.addSubview(selectedOverlay)
        backgroundColor = .clear

        selectedOverlay.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        // Setup our StackViews
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.spacing = PhotonActionSheetCell.VerticalPadding
        textStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStackView.alignment = .leading
        textStackView.axis = .vertical

        stackView.addArrangedSubview(statusIcon)
        stackView.addArrangedSubview(textStackView)
        contentView.addSubview(stackView)

        statusIcon.snp.makeConstraints { make in
            make.size.equalTo(PhotonActionSheetCellUX.StatusIconSize)
        }

        let padding = PhotonActionSheetCell.Padding
        let topPadding = PhotonActionSheetCell.HorizontalPadding
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: topPadding, left: padding, bottom: topPadding, right: padding))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with action: PhotonActionSheetItem) {
        titleLabel.text = action.title
        titleLabel.textColor = UIColor.legacyTheme.tableView.rowText
        if let tint = action.iconTint {
            titleLabel.textColor = tint
        }
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.minimumScaleFactor = 0.5

        subtitleLabel.text = action.text
        subtitleLabel.textColor = UIColor.legacyTheme.tableView.rowText
        subtitleLabel.isHidden = action.text == nil
        subtitleLabel.numberOfLines = 0
        titleLabel.font = action.bold ? DynamicFontHelper.defaultHelper.DeviceFontLargeBold : DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS
        accessibilityIdentifier = action.iconString ?? action.accessibilityId
        accessibilityLabel = action.title
        selectionStyle = action.tapHandler != nil ? .default : .none

        if let iconName = action.iconString {
            switch action.iconType {
            case .Image:
                let image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
                statusIcon.image = image
                statusIcon.tintColor = action.iconTint ?? self.tintColor
            case .SystemImage:
                let image = UIImage(systemName: iconName)
                statusIcon.image = image
                statusIcon.tintColor = action.iconTint ?? self.tintColor
            }
            if statusIcon.superview == nil {
                if action.iconAlignment == .right {
                    stackView.addArrangedSubview(statusIcon)
                } else {
                    stackView.insertArrangedSubview(statusIcon, at: 0)
                }
            } else {
                if action.iconAlignment == .right {
                    statusIcon.removeFromSuperview()
                    stackView.addArrangedSubview(statusIcon)
                }
            }
        } else {
            statusIcon.removeFromSuperview()
        }

        action.customRender?(titleLabel, contentView)
    }
}
