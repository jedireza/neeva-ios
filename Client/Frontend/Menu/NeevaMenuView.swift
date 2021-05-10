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
                    NeevaMenuButtonView(label: "Home", nicon: .house, isDisabled: self.isPrivate)
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.home)})
                        .disabled(self.isPrivate)
                    NeevaMenuButtonView(label: "Spaces", nicon: .bookmark, isDisabled: self.isPrivate)
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.spaces)})
                        .disabled(self.isPrivate)
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)

                HStack(spacing: NeevaUIConstants.menuInnerSectionPadding){
                    NeevaMenuButtonView(label: "Downloads", symbol: .squareAndArrowDown)
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.downloads)})
                    NeevaMenuButtonView(label: "History", symbol: .clock)
                        .accessibilityIdentifier("NeevaMenu.History")
                        .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.history)})
                }
                .background(Color.clear)
                .cornerRadius(NeevaUIConstants.menuCornerDefault)
            }

            VStack(spacing: 0) {
                NeevaMenuRowButtonView(label:"Settings", nicon: .gear)
                    .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                    .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                    .accessibilityIdentifier("NeevaMenu.Settings")
                    .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.settings)})
                Divider()
                NeevaMenuRowButtonView(label:"Send Feedback", nicon: .bubbleLeft)
                    .padding([.leading, .top, .bottom], NeevaUIConstants.buttonInnerPadding)
                    .padding(.trailing, NeevaUIConstants.buttonInnerPadding - 6)
                    .onTapGesture(perform: {self.menuAction!(NeevaMenuButtonActions.feedback)})
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
