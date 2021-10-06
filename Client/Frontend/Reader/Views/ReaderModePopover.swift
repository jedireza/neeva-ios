// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct ReaderModePopover: View {
    let disableReadingMode: () -> Void

    @EnvironmentObject var textSizeModel: TextSizeModel
    @EnvironmentObject var model: ReaderModeModel

    var body: some View {
        VStack {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    TextSizeStepper(roundedCorners: .top, model: textSizeModel)

                    Color.groupedBackground.frame(height: 1)

                    GroupedCell {
                        HStack {
                            ReaderModeColorPicker(
                                theme: .light,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(Text("Light Theme"))

                            Spacer()

                            ReaderModeColorPicker(
                                theme: .sepia,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(Text("Sepia Theme"))

                            Spacer()

                            ReaderModeColorPicker(
                                theme: .dark,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(Text("Dark Theme"))
                        }
                    }.accessibilityLabel(Text("Reading Mode Theme"))

                    Color.groupedBackground.frame(height: 1)

                    GroupedCell(
                        content: {
                            HStack {
                                OverlayStepperButton(
                                    action: model.brightnessModel.decrease,
                                    symbol: Symbol(decorative: .minus, style: .bodyLarge),
                                    foregroundColor: model.brightnessModel.canDecrease
                                        ? .label : .tertiaryLabel
                                )
                                .disabled(!model.brightnessModel.canDecrease)

                                Spacer()
                                model.brightnessModel.symbol
                                Spacer()

                                OverlayStepperButton(
                                    action: model.brightnessModel.increase,
                                    symbol: Symbol(decorative: .plus, style: .bodyLarge),
                                    foregroundColor: model.brightnessModel.canIncrease
                                        ? .label : .tertiaryLabel
                                )
                                .disabled(!model.brightnessModel.canIncrease)
                            }.padding(.horizontal, -GroupedCellUX.padding)
                        }, roundedCorners: .bottom
                    )
                    .buttonStyle(TableCellButtonStyle())
                    .accessibilityElement(children: .ignore)
                    .modifier(
                        OverlayStepperAccessibilityModifier(
                            accessibilityLabel: "Screen Brightness",
                            increment: model.brightnessModel.increase,
                            decrement: model.brightnessModel.decrease))
                }
            }

            GroupedCell {
                Button {
                    disableReadingMode()
                } label: {
                    Text("Close Reading Mode")
                        .withFont(.bodyLarge)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 165)

                    Spacer()
                        .padding(.horizontal)

                    Symbol(decorative: .docPlaintext, style: .headingLarge)
                }
                .foregroundColor(.label)
                .accessibilityLabel(Text("Close Reading Mode"))
            }
        }
        .padding()
        .background(
            Color.groupedBackground
                .cornerRadius(GroupedCellUX.cornerRadius, corners: .top)
                .ignoresSafeArea()
        )
        .background(
            RoundedRectangle(cornerRadius: GroupedCellUX.cornerRadius)
                .fill(Color.black.opacity(0.12))
                .blur(radius: 16)
                .offset(y: 4)
        )
    }
}

struct ReaderModePopover_Previews: PreviewProvider {
    static var previews: some View {
        ReaderModePopover(disableReadingMode: {})
            .environmentObject(
                ReaderModeModel(
                    setReadingMode: { _ in }, tabManager: SceneDelegate.getTabManager(for: nil)))
    }
}
