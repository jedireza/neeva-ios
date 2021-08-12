// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

enum RatingsCardState {
    case rateExperience
    case sendFeedback
    case appStoreReview
}

struct RatingsCard: View {
    
    @State var state = RatingsCardState.rateExperience
    let onClose: () -> Void
    var viewWidth: CGFloat
    
    // this number is from the Figma mock
    let minimumButtonWidth: CGFloat = 250

    var secondButtonProminent: Bool {
        switch state {
        case .rateExperience: return false
        default: return true
        }
    }

    var color: Color {
        return Color(light: .hex(0xFFFDF5), dark: .hex(0xF8C991))
    }
    
    func leftButtonFunction () -> Void {
        switch state {
        case .rateExperience:
            state = .sendFeedback
        default: onClose()
        }
    }

    func rightButtonFunction () -> Void {
        switch state {
        case .rateExperience:
            state = .appStoreReview
        case .sendFeedback:
            break // present feedback page
        case .appStoreReview:
            break // request app store review
        }
    }
    
    @ViewBuilder
    var leftButtonLabel: some View {
        switch state {
        case .rateExperience:
            Text("😕 Needs work")
                .withFont(.bodyLarge)
        case .sendFeedback, .appStoreReview:
            Text("Maybe later")
                .withFont(.bodyLarge)
        }
    }

    @ViewBuilder
    var rightButtonLabel: some View {
        switch state {
        case .rateExperience:
            Text("😍 Loving it!")
                .withFont(.bodyLarge)
        case .sendFeedback, .appStoreReview:
            Text("Let's do it!")
                .bold()
                .withFont(.bodyLarge)
        }
    }
    
    @ViewBuilder
    var title: some View {
        switch state {
        case .rateExperience:
            Text("How's your Neeva experience?")
                .withFont(.bodyMedium)
                .multilineTextAlignment(.center)
        case .sendFeedback:
            Text("✍️").font(.system(size: 32))
            Text("We hear you. Send feedback to help us make Neeva better for you!")
                .withFont(.bodyMedium)
                .multilineTextAlignment(.center)
        case .appStoreReview:
            Text("😍").font(.system(size: 32))
            Text("Spread the cheer on the App Store? Your review will help Neeva grow.")
                .withFont(.bodyMedium)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    var buttons: some View {
        HStack(spacing: 10) {
            Button(action: self.leftButtonFunction) {
                HStack {
                    Spacer()
                    leftButtonLabel
                    Spacer()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.label)
                .frame(height: 48)
                .background(Capsule().fill(Color.quaternarySystemFill))
            }
            Button(action: self.rightButtonFunction) {
                HStack {
                    Spacer()
                    rightButtonLabel
                    Spacer()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(secondButtonProminent ? .white : .label)
                .frame(height: 48)
                .background(Capsule().fill(secondButtonProminent ? Color.brand.blue : .quaternarySystemFill))
            }
        }

    }

    @ViewBuilder
    var label: some View {
        let size: CGFloat = 24
        let lineSpacing = 32 - size

        title
            .font(.roobert(.regular, size: size))
            .lineSpacing(lineSpacing)
            .foregroundColor(.label)
            .padding(.vertical, 0)
    }

    var background: some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        let innerShadowAmount: CGFloat = 1.25
        return
            shape
            .fill(color)
            .background(
                shape
                    .fill(Color.black.opacity(0.03))
                    .blur(radius: 0.5)
                    .offset(y: -0.5)
            )
            .overlay(
                // Reference: https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
                shape
                    .inset(by: -innerShadowAmount)
                    .stroke(Color.black.opacity(0.2), lineWidth: innerShadowAmount * 2)
                    .blur(radius: 0.5)
                    .offset(y: -innerShadowAmount)
                    .mask(shape)
            )

    }

    var isHorizontal: Bool {
        // button takes up roughly 1/2.5 of the view width
        return viewWidth / 2.5 > minimumButtonWidth
    }

    var body: some View {
        Group {
            if isHorizontal {
                HStack {
                    label
                    Spacer()
                    buttons
                }
            } else {
                VStack(spacing: 16) {
                    label
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    buttons
                }
            }
        }
        
        .padding(25)
        .background(background)
        .frame(maxWidth: 650)
        .padding()
    }

}

struct RatingsCard_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geom in  RatingsCard(state: RatingsCardState.rateExperience, onClose: {}, viewWidth: geom.size.width) }
        GeometryReader { geom in  RatingsCard(state: RatingsCardState.sendFeedback, onClose: {}, viewWidth: geom.size.width) }
        GeometryReader { geom in  RatingsCard(state: RatingsCardState.appStoreReview, onClose: {}, viewWidth: geom.size.width) }
    }
}

