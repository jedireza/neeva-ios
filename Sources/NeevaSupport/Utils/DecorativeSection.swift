//
//  DecorativeSection.swift
//  
//
//  Created by Jed Fox on 1/11/21.
//

import SwiftUI

struct DecorativeSection<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        Section(header: EmptyView().accessibilityHidden(true), content: content)
    }
}
