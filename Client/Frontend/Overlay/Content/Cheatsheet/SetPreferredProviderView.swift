// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

struct SetPreferredProviderContent: View {
    let chromeModel: TabChromeModel
    let toastViewManager: ToastViewManager
    let tabUUID: String?

    var body: some View {
        SetPreferredProviderView(
            chromeModel: chromeModel,
            toastViewManager: toastViewManager,
            performAction: { action in chromeModel.toolbarDelegate?.performTabToolbarAction(action)
            },
            tabUUID: tabUUID
        )
        .overlayIsFixedHeight(isFixedHeight: true)
        .padding(.top, -8)
    }
}

struct SetPreferredProviderView: View {
    let chromeModel: TabChromeModel
    let toastViewManager: ToastViewManager
    let performAction: (ToolbarAction) -> Void
    let tabUUID: String?

    var selectedPreference: UserPreference {
        return ProviderList.shared.getPreferenceByDomain(domain: chromeModel.currentCheatsheetURL?.baseDomain?.asURL?.absoluteString ?? "")
    }

    var currentSite: String {
        return self.chromeModel.currentCheatsheetURL?.absoluteString.asURL?.baseDomain ?? "current site"
    }

    @Environment(\.hideOverlay) private var hideOverlay

    init(
        chromeModel: TabChromeModel,
        toastViewManager: ToastViewManager,
        performAction: @escaping (ToolbarAction) -> Void,
        tabUUID: String?
    ) {
        self.chromeModel = chromeModel
        self.toastViewManager = toastViewManager
        self.performAction = performAction
        self.tabUUID = tabUUID
    }

    var body: some View {
        VStack {
            PreferenceRowView(
                rowOption: .preferMore,
                toastViewManager: toastViewManager,
                isActive: selectedPreference == .prioritized,
                tabUUID: self.tabUUID
            )
            .environmentObject(chromeModel)
            PreferenceRowView(
                rowOption: .noPreference,
                toastViewManager: toastViewManager,
                isActive: selectedPreference == .noPreference,
                tabUUID: self.tabUUID
            )
            .environmentObject(chromeModel)
            PreferenceRowView(
                rowOption: .preferLess,
                toastViewManager: toastViewManager,
                isActive: selectedPreference == .deprioritized,
                tabUUID: self.tabUUID
            )
            .environmentObject(chromeModel)
            Color.ui.adaptive.separator
                .frame(height: 0.5)
            HStack {
                Text(
                    "Select your preference for \(currentSite)"
                )
                .withFont(.bodySmall)
                .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            bottomBar
        }
        .padding(.top, 24)
    }

    @ViewBuilder
    var bottomBar: some View {
        VStack {
            Color.ui.adaptive.separator
                .frame(height: 0.5)
                .ignoresSafeArea()
            HStack(spacing: 0) {
                TabToolbarButtons.ShareButton(
                    weight: .medium, action: { performAction(.share) })
                TabToolbarButtons.ShowPreferenceButton(
                    weight: .medium, action: { hideOverlay() })
                TabToolbarButtons.AddToSpace(
                    weight: .medium, action: { performAction(.addToSpace) })
            }
            .padding(.top, 2)
            .opacity(chromeModel.controlOpacity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("CheatsheetToolBar")
            .environmentObject(chromeModel)
            Spacer()
        }
        .background(Color.DefaultBackground.ignoresSafeArea())
        .accentColor(.label)
    }
}

public enum PreferenceState: String {
    case preferMore = "Prefer More"
    case noPreference = "No Preference"
    case preferLess = "Prefer Less"

    var requestValue: UserPreference {
        switch self {
        case .preferMore:
            return .prioritized
        case .noPreference:
            return .noPreference
        case .preferLess:
            return .deprioritized
        }
    }

    @ViewBuilder
    var regularIcon: some View {
        switch self {
        case .preferMore:
            Symbol(decorative: .handThumbsup, style: .labelLarge)
                .foregroundColor(.secondary)
        case .noPreference:
            Symbol(decorative: .person, style: .labelLarge)
                .foregroundColor(.secondary)
        case .preferLess:
            Symbol(decorative: .handThumbsdown, style: .labelLarge)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    var activeIcon: some View {
        switch self {
        case .preferMore:
            Symbol(decorative: .handThumbsupFill, style: .labelLarge)
                .foregroundColor(Color.ui.adaptive.blue)
        case .noPreference:
            Symbol(decorative: .personFill, style: .labelLarge)
                .foregroundColor(Color.ui.adaptive.blue)
        case .preferLess:
            Symbol(decorative: .handThumbsdownFill, style: .labelLarge)
                .foregroundColor(Color.ui.adaptive.blue)
        }
    }
}

struct PreferenceRowView: View {
    let rowOption: PreferenceState
    let toastViewManager: ToastViewManager
    var isActive: Bool
    let tabUUID: String?

    @EnvironmentObject private var chromeModel: TabChromeModel
    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        Button(action: submitPreference) {
            HStack {
                if isActive {
                    rowOption.activeIcon
                } else {
                    rowOption.regularIcon
                }
                Text(rowOption.rawValue)
                    .withFont(unkerned: .labelLarge)
                    .foregroundColor(
                        isActive
                            ? Color.ui.adaptive.blue : .label
                    )
                    .padding(.trailing, 16)
                Spacer()
                Symbol(
                    decorative: isActive
                        ? .largecircleFillCircle : .circle, style: .labelLarge
                )
                .foregroundColor(
                    isActive
                        ? Color.ui.adaptive.blue : .secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    func submitPreference() {
        if let tabUUID = self.tabUUID, let url = chromeModel.currentCheatsheetURL?.absoluteString {
            RecipeCheatsheetLogManager.shared.logInteraction(logType: .updatePreferredProvider, tabUUIDAndURL: tabUUID + url)
        }
        
        hideOverlay()
        if let url = chromeModel.currentCheatsheetURL?.absoluteString {
            let preferenceRequest = PreferredProviderRequest(
                preference: SetProviderPreferenceMutation(
                    input: .init(
                        domain: url,
                        preference: rowOption.requestValue,
                        providerCategory: ProviderCategory.recipes
                    )
                )
            ) {
                ProviderList.shared.fetchProviderList()
            }

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5
            ) {
                ToastDefaults().showToastForSetPreferredProvider(
                    request: preferenceRequest,
                    toastViewManager: toastViewManager)
            }
        }
    }
}
