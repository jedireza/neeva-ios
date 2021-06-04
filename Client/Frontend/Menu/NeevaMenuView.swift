//
//  NeevaMenuView.swift
//
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

public struct NeevaMenuView: View {
    private let isPrivate: Bool
    private let noTopPadding: Bool

    var menuAction: ((NeevaMenuButtonActions) -> ())? = nil

    /// - Parameters:
    ///   - isPrivate: true if current tab is in private mode, false otherwise
    public init(isPrivate: Bool, noTopPadding: Bool = false) {
        self.isPrivate = isPrivate
        self.noTopPadding = noTopPadding
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: NeevaUIConstants.menuSectionPadding) {
            VStack(spacing: NeevaUIConstants.menuInnerSectionPadding) {
                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    Button {
                        self.menuAction!(NeevaMenuButtonActions.home)
                    } label: {
                        NeevaMenuButtonView(label: "Home", nicon: .house, isDisabled: self.isPrivate)
                    }
                    .accessibilityIdentifier("NeevaMenu.Home")
                    .disabled(self.isPrivate)

                    Button {
                        self.menuAction!(NeevaMenuButtonActions.spaces)
                    } label: {
                        NeevaMenuButtonView(label: "Spaces", nicon: .bookmarkOnBookmark, isDisabled: self.isPrivate)
                    }
                    .accessibilityIdentifier("NeevaMenu.Spaces")
                    .disabled(self.isPrivate)
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)

                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    Button {
                        self.menuAction!(NeevaMenuButtonActions.settings)
                    } label: {
                        NeevaMenuButtonView(label: "Settings", nicon: .gear)
                    }
                    .accessibilityIdentifier("NeevaMenu.Settings")

                    Button {
                        self.menuAction!(NeevaMenuButtonActions.feedback)
                    } label: {
                        NeevaMenuButtonView(label: "Feedback", symbol: .bubbleLeft)
                    }
                    .accessibilityIdentifier("NeevaMenu.Feedback")
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }

            VStack(spacing: 0) {
                Button {
                    self.menuAction!(NeevaMenuButtonActions.history)
                } label: {
                    NeevaMenuRowButtonView(label:"History", symbol: .clock)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.History")

                Divider()

                Button {
                    self.menuAction!(NeevaMenuButtonActions.downloads)
                } label: {
                    NeevaMenuRowButtonView(label:"Downloads", symbol: .squareAndArrowDown)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.Downloads")
            }
            .padding(0)
            .background(Color(UIColor.PopupMenu.foreground))
            .cornerRadius(NeevaUIConstants.menuCornerDefault)
        }
        .padding(self.noTopPadding ? [.leading, .trailing] : [.leading, .trailing, .top], NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.PopupMenu.background))
    }
}

struct NeevaMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuView(isPrivate: false)
        NeevaMenuView(isPrivate: true)
    }
}
