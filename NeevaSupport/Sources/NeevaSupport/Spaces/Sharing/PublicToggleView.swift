//
//  PublicToggleView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

/// Allows the user to toggle whether the space is public
struct PublicToggleView: View {
    /// Binding to the space’s public status
    @Binding var isPublic: Bool
    /// Whether the public status is currently being updated
    let isUpdating: Bool
    /// The ID of the space, which will be interpolated into the public space link
    let spaceId: String

    @State private var showingSuccessMessage = false

    var body: some View {
        DecorativeSection {
            Toggle(isOn: $isPublic) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Share Publicly")
                        Text("Anyone with the link can view.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if isUpdating {
                        Spacer()
                        ActivityIndicator()
                    }
                }
            }.disabled(isUpdating)
            .padding(.vertical, 5)
            if isPublic {
                HStack {
                    let url = NeevaConstants.appURL / "spaces" / spaceId
                    Button(action: {
                        UIPasteboard.general.url = url
                        withAnimation {
                            showingSuccessMessage = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            UIAccessibility.post(notification: .announcement, argument: "Copied link")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                            withAnimation {
                                showingSuccessMessage = false
                            }
                        }
                    }) {
                        Label("Copy public space link", systemImage: "square.on.square")
                            .labelStyle(IconOnlyLabelStyle())
                    }
                    Text(showingSuccessMessage ? "Copied!" : url.absoluteString)
                        .font(.caption)
                        .foregroundColor(showingSuccessMessage ? .primary : .secondary)
                        .lineLimit(1)
                        .accessibilitySortPriority(-1)
                        .accessibilityLabel("Space link")
                        .accessibilityValue(url.absoluteString)

                    Spacer(minLength: 0)
                    Button(action: {
                        let share = UIActivityViewController(activityItems: [url], applicationActivities: [])
                        UIApplication.shared.frontViewController.present(share, animated: true, completion: nil)
                    }) {
                        Label("Share public space link", systemImage: "square.and.arrow.up")
                            .labelStyle(IconOnlyLabelStyle())
                    }
                }.buttonStyle(BorderlessButtonStyle())
            }
        }

    }
}

struct PublicToggleView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            PublicToggleView(isPublic: .constant(true), isUpdating: false, spaceId: "abcdef")

            PublicToggleView(isPublic: .constant(true), isUpdating: true, spaceId: "abcdef")

            Section {}

            PublicToggleView(isPublic: .constant(false), isUpdating: false, spaceId: "abcdef")
            PublicToggleView(isPublic: .constant(false), isUpdating: true, spaceId: "abcdef")
        }
    }
}

