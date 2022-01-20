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

    public init(symbol: Symbol, selectedIconColor: Color, selectedColor: Color) {
        self.symbol = symbol
        self.selectedIconColor = selectedIconColor
        self.selectedColor = selectedColor
    }
}

struct SegmentTappedModifier: ViewModifier {
    let index: Int
    let segment: Segment
    @Binding var selectedSegmentIndex: Int

    func body(content: Content) -> some View {
        Button(action: { selectedSegmentIndex = index }) {
            content
        }
        .accessibilityAddTraits(index == selectedSegmentIndex ? .isSelected : [])
    }
}

public struct SegmentedPicker: View {
    private let segmentWidth: CGFloat = 72
    private let segmentHeight: CGFloat = 36
    let segments: [Segment]
    var dragOffset: CGFloat? = nil

    @State var actualSelectedSegment: Int
    @Binding var selectedSegmentIndex: Int
    @GestureState var pressed = false

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
        segmentWidth * CGFloat(actualSelectedSegment - 1) + evenSegmentOffset + (dragOffset ?? 0)
    }

    @ViewBuilder private var segment: some View {
        // Not sure where sqrt() and 1.5 come from, but they do feel nice
        let shrinkRatio = min(sqrt(1.5 * max(minMaxOffset, 1) / max(abs(offset), 1)), 1)
        let width = max(segmentHeight, segmentWidth * shrinkRatio)
        Capsule()
            .background(
                Capsule()
                    .fill(Color(light: .black.opacity(0.15), dark: .black.opacity(0.75)))
                    .offset(y: pressed ? 0 : 1)
                    .animation(.interactiveSpring(), value: pressed)
            )
            .scaleEffect(pressed ? 0.9 : 1)
            .offset(x: offset.clamp(min: -minMaxOffset, max: minMaxOffset))
            .animation(.interactiveSpring(), value: pressed)
            .animation(dragOffset == nil ? .interactiveSpring() : nil, value: offset)
            .frame(width: width, height: segmentHeight)
            .offset(x: Double(signOf: offset, magnitudeOf: 0.5) * (segmentWidth - width))
            .padding(.horizontal, 3)
    }

    private func icons(selected: Bool) -> some View {
        HStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { (index, segment) in
                HStack {
                    Spacer()

                    if selected {
                        segment.symbol
                            .foregroundColor(segment.selectedIconColor)
                    } else {
                        segment.symbol
                            .foregroundColor(.label)
                    }

                    Spacer()
                }
                .frame(height: segmentHeight)
                .if(!selected) {
                    $0.modifier(
                        SegmentTappedModifier(
                            index: index, segment: segment,
                            selectedSegmentIndex: $selectedSegmentIndex))
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
                .foregroundColor(segments[selectedSegmentIndex].selectedColor)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating(
                            $pressed,
                            body: { _, state, _ in
                                state = true
                            })
                )

            icons(selected: true)
                .mask(segment)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .frame(width: segmentWidth * CGFloat(segments.count))
        .onChange(of: selectedSegmentIndex) {
            if dragOffset == nil {
                actualSelectedSegment = $0
            }
        }
        .onChange(of: dragOffset) { offset in
            guard let offset = offset else {
                // Drag ended
                actualSelectedSegment = selectedSegmentIndex
                return
            }

            // Add a small boost to the offset since the picker already starts in the middle of one the segments.
            let boost = offset < 0 ? -0.5 : 0.5
            // Prevents the placeholder from jumping to the last segment.
            let jumpPrevention = abs(selectedSegmentIndex - actualSelectedSegment)
            var proposedPlaceholderChange = Int((offset / segmentWidth) + boost)

            if offset < 0 {
                proposedPlaceholderChange += jumpPrevention
            } else {
                proposedPlaceholderChange -= jumpPrevention
            }

            if segments.indices.contains(selectedSegmentIndex + proposedPlaceholderChange) {
                let newSelectedIndex = selectedSegmentIndex + proposedPlaceholderChange

                if newSelectedIndex != selectedSegmentIndex {
                    selectedSegmentIndex = newSelectedIndex
                    Haptics.selection()
                }
            }
        }
    }

    public init(segments: [Segment], selectedSegmentIndex: Binding<Int>, dragOffset: CGFloat? = nil)
    {
        self.segments = segments
        self._selectedSegmentIndex = selectedSegmentIndex
        self._actualSelectedSegment = .init(initialValue: selectedSegmentIndex.wrappedValue)
        self.dragOffset = dragOffset
    }
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPicker(
            segments: [
                Segment(
                    symbol: Symbol(decorative: .incognito, weight: .medium),
                    selectedIconColor: .background, selectedColor: .label),
                Segment(
                    symbol: Symbol(decorative: .squareOnSquare, weight: .medium),
                    selectedIconColor: .white, selectedColor: .brand.blue),
                Segment(
                    symbol: Symbol(decorative: .bookmarkOnBookmark),
                    selectedIconColor: .white, selectedColor: .brand.blue),
            ], selectedSegmentIndex: .constant(1))
    }
}
