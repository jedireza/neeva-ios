//
//  NeevaMenuView.swift
//
//
//  Created by Stuart Allen on 3/13/21.
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
                        NeevaMenuButtonView(label: "Spaces", nicon: .bookmark, isDisabled: self.isPrivate)
                    }
                    .accessibilityIdentifier("NeevaMenu.Spaces")
                    .disabled(self.isPrivate)
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)

                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    Button {
                        self.menuAction!(NeevaMenuButtonActions.downloads)
                    } label: {
                        NeevaMenuButtonView(label: "Downloads", symbol: .squareAndArrowDown)
                    }
                    .accessibilityIdentifier("NeevaMenu.Downloads")

                    Button {
                        self.menuAction!(NeevaMenuButtonActions.history)
                    } label: {
                        NeevaMenuButtonView(label: "History", symbol: .clock)
                    }
                    .accessibilityIdentifier("NeevaMenu.History")
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }

            VStack(spacing: 0) {
                Button {
                    self.menuAction!(NeevaMenuButtonActions.settings)
                } label: {
                    NeevaMenuRowButtonView(label:"Settings", nicon: .gear)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.Settings")

                Divider()

                Button {
                    self.menuAction!(NeevaMenuButtonActions.feedback)
                } label: {
                    NeevaMenuRowButtonView(label:"Send Feedback", nicon: .bubbleLeft)
                        .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                        .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                }
                .accessibilityIdentifier("NeevaMenu.Feedback")
            }
            .padding(0)
            .background(Color(UIColor.theme.popupMenu.foreground))
            .cornerRadius(NeevaUIConstants.menuCornerDefault)
        }
        .padding(self.noTopPadding ? [.leading, .trailing, .bottom] : [.leading, .trailing, .bottom, .top], NeevaUIConstants.menuOuterPadding)
        .background(Color(UIColor.theme.popupMenu.background))
    }
}

struct NeevaMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuView(isPrivate: false)
     }
}
