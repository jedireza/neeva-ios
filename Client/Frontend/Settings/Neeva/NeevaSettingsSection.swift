// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import WebKit

struct NeevaSettingsSection: View {
    @ObservedObject var userInfo: NeevaUserInfo
    @Environment(\.openInNewTab) var openURL
    @State var showingAccountDetails = false

    static var webView: WKWebView = {
        let config = TabManager.makeWebViewConfig(isPrivate: false)
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(
            frame: CGRect(width: 1, height: 1),
            configuration: config
        )
        webView.allowsLinkPreview = false
        webView.customUserAgent = UserAgent.neevaAppUserAgent()
        webView.load(URLRequest(url: NeevaConstants.appSettingsURL))

        return webView
    }()

    @GestureState private var isTapped = false
    @State var showingSettings = false
    @State var loaderOpacity = 0.0
    @State var userInfoOpacity = 1.0

    var body: some View {
        if userInfo.isLoading {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading account info…").foregroundColor(.secondaryLabel)
            }
            .frame(height: 60 - 12)
            .opacity(loaderOpacity)
            .animation(.default)
            .onAppear {
                loaderOpacity = 1
            }.onDisappear {
                loaderOpacity = 0
            }
        } else if userInfo.isUserLoggedIn {
            NavigationLink(destination: NeevaAccountInfoView(userInfo: userInfo, isPresented: $showingAccountDetails), isActive: $showingAccountDetails) {
                NeevaAccountRow(userInfo: userInfo)
            }

            // TODO: fix adding connectors on this screen
            if FeatureFlag[.inlineAccountSettings] {
                NavigationLink(
                    "Account Settings",
                    destination: AccountSettingsView(webView: Self.webView)
                        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
                        .navigationTitle("Account Settings")
                        .onAppear {
                            ClientLogger.shared.logCounter(.SettingAccountSettings, attributes: EnvironmentHelper.shared.getAttributes())
                        }
                )
            } else {
                NavigationLinkButton("Account Settings") {
                    ClientLogger.shared.logCounter(.SettingAccountSettings, attributes: EnvironmentHelper.shared.getAttributes())
                    openURL(NeevaConstants.appSettingsURL, false)
                    BrowserViewController.foregroundBVC().dismissVC()
                }
            }

            NavigationLinkButton("Connected Apps") {
                // if user is in a tour, trigger navigation on webui side to
                // prevent page refresh, which will cause lost of states
                if TourManager.shared.userReachedStep(step: .promptSettingsInNeevaMenu, tapTarget: .connectedApps) != .stopAction {
                    openURL(NeevaConstants.appConnectionsURL, false)
                } else {
                    BrowserViewController.foregroundBVC().dismissVC()
                }
            }.if (TourManager.shared.isCurrentStep(with: .promptSettingsInNeevaMenu)) { view in
                view.throbbingHighlightBorderStyle(highlight: Color.Tour.Background, staticColorMode: true)
            }
        } else {
            Button("Sign In or Join Neeva") {
                ClientLogger.shared.logCounter(.SettingSignin, attributes: EnvironmentHelper.shared.getAttributes())
                openURL(NeevaConstants.appSigninURL, false)
            }.frame(height: 60 - 12)
        }
        NavigationLink("Default Browser", destination: DefaultBrowserSetting_().onAppear(perform: {
            ClientLogger.shared.logCounter(.SettingDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
        }))
    }
}

struct DefaultBrowserSetting_: View {
    var body: some View {
        List {
            SwiftUI.Section(header: Text("Open links in Neeva automatically by making it your Default Browser App").font(.body).textCase(nil).padding(.vertical)) {
                Button("Set as Default Browser") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Default Browser")
    }
}

struct AccountSettingsView: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> some UIView { webView }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NeevaSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            SwiftUI.Section(header: Text("Neeva — Logged in")) {
                NeevaSettingsSection(userInfo: NeevaUserInfo(previewDisplayName: "First Last", email: "name@example.com", pictureUrl: "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg", authProvider: .apple))
            }
            SwiftUI.Section(header: Text("Neeva — Logged out")) {
                NeevaSettingsSection(userInfo: .previewLoggedOut)
            }
            SwiftUI.Section(header: Text("Neeva — Fetching status")) {
                NeevaSettingsSection(userInfo: .previewLoading)
            }
        }
    }
}
