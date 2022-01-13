// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    var currentIndex: Int
    @Binding var selectedSegmentIndex: Int

    func body(content: Content) -> some View {
        Button(action: {
            segment.selectedAction()
            selectedSegmentIndex = index
        }) {
            content
        }
    }
}

public struct SegmentedPicker: View {
    private let segmentWidth: CGFloat = 72
    let segments: [Segment]
    var dragOffset: CGFloat? = nil

    @Binding var selectedSegmentIndex: Int
    @GestureState var pressed = false
    @State var placeholderIndex: Int? = nil

    var currentIndex: Int {
        guard let placeholderIndex = placeholderIndex else {
            return selectedSegmentIndex
        }

        return placeholderIndex != selectedSegmentIndex ? placeholderIndex : selectedSegmentIndex
    }

    var evenSegmentCount: Bool {
        CGFloat(segments.count).truncatingRemainder(dividingBy: 2) == 0
    }

    var evenSegmentOffset: CGFloat {
        evenSegmentCount ? segmentWidth / 2 : 0
    }

    var middleSegmentIndex: Int {
        evenSegmentCount ? segments.count / 2 : Int(Double(segments.count / 2) + 0.5)
    }

    var minMaxOffset: CGFloat {
        CGFloat(segments.count - (segments.count - middleSegmentIndex)) * segmentWidth
    }

    var offset: CGFloat {
        segmentWidth * CGFloat(selectedSegmentIndex - 1) + evenSegmentOffset + (dragOffset ?? 0)
    }

    private var segment: some View {
        RoundedRectangle(cornerRadius: 18)
            .scaleEffect(pressed ? 0.9 : 1)
            .offset(x: offset.clamp(min: -minMaxOffset, max: minMaxOffset))
            .animation(.interactiveSpring(), value: pressed)
            .animation(dragOffset == nil ? .interactiveSpring() : nil, value: offset)
            .padding(.horizontal, 3)
            .frame(width: segmentWidth, height: 35)
    }

    private func icons(selected: Bool) -> some View {
        HStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { (index, segment) in
                Spacer()

                if selected {
                    segment.symbol
                        .foregroundColor(segment.selectedIconColor)
                } else {
                    segment.symbol
                        .foregroundColor(.label)
                        .modifier(
                            SegmentTappedModifier(
                                index: index, segment: segment, currentIndex: currentIndex,
                                selectedSegmentIndex: $selectedSegmentIndex))
                }

                if segments.count > 1 {
                    Spacer()
                }
            }
        }
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.secondaryBackground)
                .frame(height: 40)

            icons(selected: false)

            segment
                .foregroundColor(segments[currentIndex].selectedColor)
                .gesture(
                    DragGesture()
                        .updating($pressed, body: { _, state, _ in
                            state = true
                        })
                )

            icons(selected: true)
                .mask(segment)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(width: segmentWidth * CGFloat(segments.count))
        .onChange(of: selectedSegmentIndex) { _ in
            placeholderIndex = nil
        }
        .onChange(of: dragOffset) { offset in
            guard let offset = offset else {
                // Drag ended
                let index = placeholderIndex ?? selectedSegmentIndex
                segments[index].selectedAction()
                selectedSegmentIndex = index
                placeholderIndex = nil

                return
            }

            // Add a small boost to the offset since the picker already starts in the middle of one the segments.
            let boost = offset < 0 ? -0.5 : 0.5
            // Prevents the placeholder from jumping to the last segment.
            let jumpPrevention = abs(
                selectedSegmentIndex - (placeholderIndex ?? selectedSegmentIndex))
            var proposedPlaceholderChange = Int((offset / segmentWidth) + boost)

            if offset < 0 {
                proposedPlaceholderChange += jumpPrevention
            } else {
                proposedPlaceholderChange -= jumpPrevention
            }

            if segments.indices.contains(
                (placeholderIndex ?? selectedSegmentIndex) + proposedPlaceholderChange)
            {
                let newPlaceholderIndex =
                    (placeholderIndex ?? selectedSegmentIndex) + proposedPlaceholderChange

                if newPlaceholderIndex != placeholderIndex {
                    placeholderIndex = newPlaceholderIndex
                    segments[newPlaceholderIndex].selectedAction()
                    if proposedPlaceholderChange != 0 {
                        Haptics.swipeGesture()
                    }
                }
            }
        }
    }

    public init(segments: [Segment], selectedSegmentIndex: Binding<Int>, dragOffset: CGFloat? = nil)
    {
        self.segments = segments
        self._selectedSegmentIndex = selectedSegmentIndex
        self.dragOffset = dragOffset
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
