//
//  PublicToggleView.swift
//  
//
//  Created by Jed Fox on 1/6/21.
//

import SwiftUI

struct PublicToggleView: View {
    @Binding var isPublic: Bool
    let isUpdating: Bool
    let spaceId: String

    @State private var showingSuccessMessage = false

    var body: some View {
        Section {
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
                    let url = "https://\(NeevaConstants.appHost)/spaces/\(spaceId)"
                    Button(action: {
                        UIPasteboard.general.url = URL(string: url)
                        withAnimation {
                            showingSuccessMessage = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(3))) {
                            withAnimation {
                                showingSuccessMessage = false
                            }
                        }
                    }) {
                        Image(systemName: "square.on.square")
                    }
                    Text(showingSuccessMessage ? "Copied!" : url)
                        .font(.caption)
                        .foregroundColor(showingSuccessMessage ? .primary : .secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button(action: {
                        let share = UIActivityViewController(activityItems: [URL(string: url)!], applicationActivities: [])
                        UIApplication.shared.frontViewController.present(share, animated: true, completion: nil)
                    }) {
                        Image(systemName: "square.and.arrow.up")
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

