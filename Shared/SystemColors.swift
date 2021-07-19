// Copyright Neeva. All rights reserved.

import SwiftUI

// MARK: System Fills
extension Color {
    /// An overlay fill color for thin and small shapes.
    /// Use this color to fill thin or small shapes, such as the track of a slider.
    ///
    /// Use system fill colors for items situated on top of an existing background color. System fill colors incorporate transparency to allow the background color to show through.
    public static let systemFill = Color(UIColor.systemFill)

    /// An overlay fill color for thin and small shapes.
    /// Use this color to fill medium-size shapes, such as the background of a switch.
    ///
    /// Use system fill colors for items situated on top of an existing background color. System fill colors incorporate transparency to allow the background color to show through.
    public static let secondarySystemFill = Color(UIColor.secondarySystemFill)

    /// An overlay fill color for thin and small shapes.
    /// Use this color to fill large shapes, such as input fields, search bars, or buttons.
    ///
    /// Use system fill colors for items situated on top of an existing background color. System fill colors incorporate transparency to allow the background color to show through.
    public static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)

    /// An overlay fill color for thin and small shapes.
    /// Use this color to fill large areas that contain complex content, such as an expanded table cell.
    ///
    /// Use system fill colors for items situated on top of an existing background color. System fill colors incorporate transparency to allow the background color to show through.
    public static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)
}

// MARK: System Text Colors
extension Color {
    /// The color for text labels that contain primary content.
    public static let label = Color.primary
    /// The color for text labels that contain secondary content.
    public static let secondaryLabel = Color.secondary
    /// The color for text labels that contain tertiary content.
    public static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    /// The color for text labels that contain quaternary content.
    public static let quaternaryLabel = Color(UIColor.quaternaryLabel)
}

// MARK: System Backgrounds
extension Color {
    /// The color for the main background of your interface.
    ///
    /// Use standard `background` colors for standard table views and designs that have a white primary background in a light environment.
    public static let background = Color(UIColor.systemBackground)

    /// The color for content layered on top of the main background.
    ///
    /// Use standard `background` colors for standard table views and designs that have a white primary background in a light environment.
    public static let secondaryBackground = Color(UIColor.secondarySystemBackground)

    /// The color for content layered on top of secondary backgrounds.
    ///
    /// Use standard `background` colors for standard table views and designs that have a white primary background in a light environment.
    public static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
}

// MARK: System Grouped Backgrounds
extension Color {
    /// The color for the main background of your grouped interface.
    ///
    /// Use `groupedBackground` colors for grouped content, including table views and platter-based designs.
    public static let groupedBackground = Color(UIColor.systemGroupedBackground)

    /// The color for content layered on top of the main background of your grouped interface.
    ///
    /// Use `groupedBackground` colors for grouped content, including table views and platter-based designs.
    public static let secondaryGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)

    /// The color for content layered on top of secondary backgrounds of your grouped interface.
    ///
    /// Use `groupedBackground` colors for grouped content, including table views and platter-based designs.
    public static let tertiaryGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
}
