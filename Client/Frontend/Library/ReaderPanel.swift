/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Storage
import Shared
import XCGLogger

private let log = Logger.browserLogger

private struct ReadingListTableViewCellUX {
    static let RowHeight: CGFloat = 86

    static let ReadIndicatorWidth: CGFloat = 12  // image width
    static let ReadIndicatorHeight: CGFloat = 12 // image height
    static let ReadIndicatorLeftOffset: CGFloat = 18
    static let ReadAccessibilitySpeechPitch: Float = 0.7 // 1.0 default, 0.0 lowest, 2.0 highest

    static let TitleLabelTopOffset: CGFloat = 14 - 4
    static let TitleLabelLeftOffset: CGFloat = 16 + 16 + 16
    static let TitleLabelRightOffset: CGFloat = -40

    static let HostnameLabelBottomOffset: CGFloat = 11

    static let DeleteButtonTitleColor = UIColor.Photon.White100
    static let DeleteButtonTitleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    static let MarkAsReadButtonBackgroundColor = UIColor.Photon.Blue50
    static let MarkAsReadButtonTitleColor = UIColor.Photon.White100
    static let MarkAsReadButtonTitleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
}

private struct ReadingListPanelUX {
    // Welcome Screen
    static let WelcomeScreenTopPadding: CGFloat = 16
    static let WelcomeScreenPadding: CGFloat = 15

    static let WelcomeScreenItemWidth = 220
    static let WelcomeScreenItemOffset = -20

    static let WelcomeScreenCircleWidth = 40
    static let WelcomeScreenCircleOffset = 20
    static let WelcomeScreenCircleSpacer = 10
}

class ReadingListTableViewCell: UITableViewCell, Themeable {
    var title: String = "Example" {
        didSet {
            titleLabel.text = title
            updateAccessibilityLabel()
        }
    }

    var url = URL(string: "http://www.example.com")! {
        didSet {
            hostnameLabel.text = simplifiedHostnameFromURL(url)
            updateAccessibilityLabel()
        }
    }

    var unread: Bool = true {
        didSet {
            readStatusImageView.image = UIImage(named: unread ? "MarkAsRead" : "MarkAsUnread")
            titleLabel.textColor = unread ? UIColor.theme.homePanel.readingListActive : UIColor.theme.homePanel.readingListDimmed
            hostnameLabel.textColor = unread ? UIColor.theme.homePanel.readingListActive : UIColor.theme.homePanel.readingListDimmed
            updateAccessibilityLabel()
        }
    }

    let readStatusImageView: UIImageView!
    let titleLabel: UILabel!
    let hostnameLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        readStatusImageView = UIImageView()
        titleLabel = UILabel()
        hostnameLabel = UILabel()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.clear

        separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        layoutMargins = .zero
        preservesSuperviewLayoutMargins = false

        contentView.addSubview(readStatusImageView)
        readStatusImageView.contentMode = .scaleAspectFit
        readStatusImageView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(ReadingListTableViewCellUX.ReadIndicatorWidth)
            make.height.equalTo(ReadingListTableViewCellUX.ReadIndicatorHeight)
            make.centerY.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(ReadingListTableViewCellUX.ReadIndicatorLeftOffset)
        }

        contentView.addSubview(titleLabel)
        contentView.addSubview(hostnameLabel)

        titleLabel.numberOfLines = 2
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelTopOffset)
            make.leading.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelLeftOffset)
            make.trailing.equalTo(self.contentView).offset(ReadingListTableViewCellUX.TitleLabelRightOffset) // TODO Not clear from ux spec
            make.bottom.lessThanOrEqualTo(hostnameLabel.snp.top).priority(1000)
        }

        hostnameLabel.numberOfLines = 1
        hostnameLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.contentView).offset(-ReadingListTableViewCellUX.HostnameLabelBottomOffset)
            make.leading.trailing.equalTo(self.titleLabel)
        }

        applyTheme()
    }

    func setupDynamicFonts() {
        titleLabel.font = DynamicFontHelper.defaultHelper.DeviceFont
        hostnameLabel.font = DynamicFontHelper.defaultHelper.DeviceFontSmallLight
    }

    func applyTheme() {
        titleLabel.textColor = UIColor.theme.homePanel.readingListActive
        hostnameLabel.textColor = UIColor.theme.homePanel.readingListActive
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applyTheme()
        setupDynamicFonts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let prefixesToSimplify = ["www.", "mobile.", "m.", "blog."]

    fileprivate func simplifiedHostnameFromURL(_ url: URL) -> String {
        let hostname = url.host ?? ""
        for prefix in prefixesToSimplify {
            if hostname.hasPrefix(prefix) {
                return String(hostname[hostname.index(hostname.startIndex, offsetBy: prefix.count)...])
            }
        }
        return hostname
    }

    fileprivate func updateAccessibilityLabel() {
        if let hostname = hostnameLabel.text,
                  let title = titleLabel.text {
            let unreadStatus: String = unread ? .ReaderPanelUnreadAccessibilityLabel : .ReaderPanelReadAccessibilityLabel
            let string = "\(title), \(unreadStatus), \(hostname)"
            var label: AnyObject
            if !unread {
                // mimic light gray visual dimming by "dimming" the speech by reducing pitch
                let lowerPitchString = NSMutableAttributedString(string: string as String)
                lowerPitchString.addAttribute(NSAttributedString.Key.accessibilitySpeechPitch, value: NSNumber(value: ReadingListTableViewCellUX.ReadAccessibilitySpeechPitch as Float), range: NSRange(location: 0, length: lowerPitchString.length))
                label = NSAttributedString(attributedString: lowerPitchString)
            } else {
                label = string as AnyObject
            }
            // need to use KVC as accessibilityLabel is of type String! and cannot be set to NSAttributedString other way than this
            // see bottom of page 121 of the PDF slides of WWDC 2012 "Accessibility for iOS" session for indication that this is OK by Apple
            // also this combined with Swift's strictness is why we cannot simply override accessibilityLabel and return the label directly...
            setValue(label, forKey: "accessibilityLabel")
        }
    }
}
