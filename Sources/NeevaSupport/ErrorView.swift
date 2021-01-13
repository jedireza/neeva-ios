//
//  ErrorView.swift
//  
//
//  Created by Jed Fox on 1/12/21.
//

import SwiftUI

public struct ErrorView: View {
    let error: Error
    let tryAgain: (() -> ())?
    let viewName: String

    public init<T: View>(_ error: Error, in _: T, tryAgain: (() -> ())? = nil) {
        self.error = error
        self.tryAgain = tryAgain
        self.viewName = "\(T.self)"
    }

    public init(_ error: Error, viewName: String, tryAgain: (() -> ())? = nil) {
        self.error = error
        self.tryAgain = tryAgain
        self.viewName = viewName
    }

    @ObservedObject private var reachability = NetworkReachability.shared
    @State private var sendingFeedback = false

    var gqlErrors: [String]? {
        (error as? GraphQLAPI.Error)?.errors.compactMap(\.message)
    }

    var isLoginError: Bool {
        guard let first = gqlErrors?.first, gqlErrors?.count == 1 else { return false }
        return first == "login required to access this field"
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("")
            if isLoginError {
                LoginView()
            } else if let isOnline = reachability.isOnline, !isOnline {
                OfflineView()
            } else {
                GenericErrorView(viewName: viewName, error: error, gqlErrors: gqlErrors)
            }
            if let tryAgain = tryAgain {
                Button(action: tryAgain) {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .font(Font.footnote.bold())
                .padding(.vertical)
            }
        }.onChange(of: reachability.isOnline) { nowOnline in
            if nowOnline == true {
                tryAgain?()
            }
        }
    }
}

struct GenericErrorView: View {
    let viewName: String
    let error: Error
    let gqlErrors: [String]?

    var errorsForFeedback: String {
        if let errors = gqlErrors {
            return "• \(errors.joined(separator: "\n• "))"
        }
        return error.localizedDescription
    }
    var body: some View {
        VStack(spacing: 20) {
            Label("Error", systemImage: "exclamationmark.octagon.fill")
            .font(Font.title.bold())
            .foregroundColor(.red)
            GroupBox {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        if let errors = gqlErrors {
                            ForEach(errors, id: \.self) { error in
                                Text(error)
                            }
                        } else {
                            Text(error.localizedDescription)
                        }
                    }
                    .font(.system(.body, design: .monospaced))
                }.frame(maxHeight: 130)
            }.padding()
            SendFeedbackView.Button(initialText: "\n\nReceived these errors in \(viewName):\n\(errorsForFeedback)")
        }
    }
}

struct LoginView: View {
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        VStack(spacing: 50) {
            Text("")
            Image.neevaLogo
            VStack(spacing: 20) {
                Text("Please sign in to continue")
                    .font(.title2)
                Text("This content can only be viewed if you sign in")
            }
            Button("Sign in to Neeva") { onOpenURL(NeevaConstants.appURL) }
                .buttonStyle(BigBlueButtonStyle())
        }.multilineTextAlignment(.center).padding()
    }
}

struct OfflineView: View {
    var body: some View {
        VStack(spacing: 20) {
            Label("You’re offline", systemImage: "bolt.slash.fill")
                .font(Font.title.bold())
                .foregroundColor(.orange)
            Text("Connect to the Internet to view this content")
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}


struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(GraphQLAPI.Error([.init(["message": "login required to access this field"])]), viewName: "\(Self.self)")
        ErrorView(GraphQLAPI.Error([.init(["message": "login required to access this field"])]), viewName: "\(Self.self)", tryAgain: {})
        ErrorView(GraphQLAPI.Error(Array(repeating: .init(["message": "failed to reticulate the splines"]), count: 10)), viewName: "\(Self.self)")
        ErrorView(GraphQLAPI.Error([.init(["message": "failed to reticulate the splines"]), .init(["message": "the server room is on fire"])]), viewName: "\(Self.self)")
        ErrorView(GraphQLAPI.Error([.init(["message": "failed to reticulate the splines"]), .init(["message": "the server room is on fire"])]), viewName: "\(Self.self)", tryAgain: {})
        OfflineView()
    }
}
