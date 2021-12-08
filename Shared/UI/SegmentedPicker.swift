// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import SwiftUI

public struct Segment {
    let id = UUID()
    var symbol: Symbol
    let selectedIconColor: Color
    let selectedColor: Color
    let selectedAction: () -> Void

    public init(
        symbol: Symbol, selectedIconColor: Color, selectedColor: Color,
        selectedAction: @escaping () -> Void
    ) {
        self.symbol = symbol
        self.selectedIconColor = selectedIconColor
        self.selectedColor = selectedColor
        self.selectedAction = selectedAction
    }
}

struct SegmentTappedModifier: ViewModifier {
    let index: Int
    let segment: Segment
    @Binding var selectedSegmentIndex: Int

    func body(content: Content) -> some View {
        content
            .foregroundColor(
                index != selectedSegmentIndex
                    ? Color.label : segment.selectedIconColor
            )
            .onTapGesture {
                segment.selectedAction()
                selectedSegmentIndex = index
            }
    }
}

public struct SegmentedPicker: View {
    let segments: [Segment]
    @Binding var selectedSegmentIndex: Int

    private let segmentWidth: CGFloat = 72

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.secondaryBackground)
                .frame(height: 40)

            RoundedRectangle(cornerRadius: 18)
                .foregroundColor(segments[selectedSegmentIndex].selectedColor)
                .offset(x: segmentWidth * CGFloat(selectedSegmentIndex - 1))
                .transition(.slide)
                .padding(.horizontal, 3)
                .frame(width: segmentWidth, height: 35)

            HStack {
                ForEach(Array(segments.enumerated()), id: \.offset) { (index, segment) in
                    Spacer()

                    segment.symbol
                        .modifier(
                            SegmentTappedModifier(
                                index: index, segment: segment,
                                selectedSegmentIndex: $selectedSegmentIndex))

                    if segments.count > 1 {
                        Spacer()
                    }
                }
            }
        }.frame(width: segmentWidth * CGFloat(segments.count))
    }

    public init(segments: [Segment], selectedSegmentIndex: Binding<Int>) {
        self.segments = segments
        self._selectedSegmentIndex = selectedSegmentIndex
    }
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPicker(
            segments: [
                Segment(
                    symbol: Symbol(decorative: .incognito, weight: .medium),
                    selectedIconColor: .background, selectedColor: .label,
                    selectedAction: {}),
                Segment(
                    symbol: Symbol(decorative: .squareOnSquare, weight: .medium),
                    selectedIconColor: .white, selectedColor: .brand.blue,
                    selectedAction: {}),
                Segment(
                    symbol: Symbol(decorative: .bookmarkOnBookmark),
                    selectedIconColor: .white, selectedColor: .brand.blue,
                    selectedAction: {}),
            ], selectedSegmentIndex: .constant(1))
    }
}
