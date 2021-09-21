// Copyright Neeva. All rights reserved.

import Social
import SwiftUI

private enum Social: String {
    case twitter = "com.apple.social.twitter"
    case linkedin = "com.apple.social.linkedin"
    case facebook = "com.apple.social.facebook"

    var serviceType: String {
        rawValue
    }

    var isAvailable: Bool {
        switch self {
        case .twitter:
            return UIApplication.shared.canOpenURL(URL(string: "twitter://")!)
        case .linkedin:
            return UIApplication.shared.canOpenURL(URL(string: "linkedin://")!)
        case .facebook:
            return UIApplication.shared.canOpenURL(URL(string: "fb://")!)
        }
    }

    static let allTypes: [Social] = [.twitter, .linkedin, .facebook]
}

struct ShareToSocialView: View {
    @Environment(\.shareURL) var shareURL
    @EnvironmentObject var tabModel: TabCardModel
    let url: URL
    let shareTargetView: UIView
    let ensurePublicACL: (@escaping () -> Void) -> Void

    init(url: URL, shareTarget: UIView, ensurePublicACL: @escaping (@escaping () -> Void) -> Void) {
        self.url = url
        self.shareTargetView = shareTarget
        self.ensurePublicACL = ensurePublicACL
    }

    private var noAppsAvailable: Bool {
        Social.allTypes.allSatisfy({ !$0.isAvailable })
    }

    var body: some View {
        HStack(spacing: 0) {
            if noAppsAvailable {
                Spacer()
            }
            if Social.twitter.isAvailable {
                SocialShareButton(
                    imageName: "twitter-share", isSystemImage: false,
                    label: "Twitter",
                    onClick: {
                        ensurePublicACL({
                            UIApplication.shared.open(
                                URL(
                                    string:
                                        "http://twitter.com/share?text=Check+out+this+@Neeva+Space!&url=\(url.absoluteString)"
                                )!,
                                options: [:], completionHandler: nil)
                        })
                    })
                Spacer()
            }
            if Social.linkedin.isAvailable {
                SocialShareButton(
                    imageName: "linkedin-share", isSystemImage: false,
                    label: "Linkedin",
                    onClick: {
                        ensurePublicACL({
                            UIApplication.shared.open(
                                URL(
                                    string:
                                        "linkedin://shareArticle?mini=true&url=\(url.absoluteString)"
                                )!,
                                options: [:], completionHandler: nil)
                        })
                    })
                Spacer()
            }
            if Social.facebook.isAvailable {
                SocialShareButton(
                    imageName: "facebook-share", isSystemImage: false,
                    label: "Facebook",
                    onClick: {
                        ensurePublicACL({
                            guard
                                let vc = SLComposeViewController(
                                    forServiceType: Social.facebook.serviceType)
                            else {
                                return
                            }
                            vc.setInitialText("Check out this Neeva Space!")
                            vc.add(url)
                            SceneDelegate.getBVC(with: tabModel.manager.scene).present(
                                vc, animated: true)
                        })
                    })
                Spacer()
            }
            SocialShareButton(
                imageName: "link", isSystemImage: true,
                label: "Copy link",
                onClick: {
                    ensurePublicACL({
                        UIPasteboard.general.url = url
                        if let toastManager = SceneDelegate.getCurrentSceneDelegate(
                            with: tabModel.manager.scene)?.toastViewManager
                        {
                            toastManager.makeToast(text: "URL copied to clipboard")
                                .enqueue(manager: toastManager)
                        }
                    })
                })
            Spacer()
            SocialShareButton(
                imageName: "square.and.arrow.up", isSystemImage: true,
                label: noAppsAvailable ? "Share" : "More",
                onClick: {
                    ensurePublicACL({ shareURL(url, shareTargetView) })
                })
            if noAppsAvailable {
                Spacer()
            }
        }.padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }
}

struct SocialShareButton: View {
    let imageName: String
    let isSystemImage: Bool
    let label: String
    let onClick: () -> Void
    @State var isPressed: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Button(
                action: onClick,
                label: {
                    Group {
                        if isSystemImage {
                            Image(systemName: imageName)
                                .foregroundColor(.secondaryLabel)
                        } else {
                            Image(imageName, bundle: .main)
                                .resizable().scaledToFit()
                        }
                    }
                    .frame(width: 18, height: 18)
                    .tapTargetFrame()
                    .background(Color.DefaultBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tertiaryLabel, lineWidth: 1))
                }
            ).buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
                .scaleEffect(isPressed ? 0.85 : 1)
            Text(label)
                .withFont(.bodySmall)
                .foregroundColor(.label)
                .padding(.top, 4)
        }
    }
}
