// Copyright Neeva. All rights reserved.

import CryptoKit
import Foundation
import Shared

extension IntroViewController {
    struct OktaAccountRequestBodyModel: Codable {
        let email: String
        let firstname: String
        let lastname: String
        let password: String
        let salt: String
        let visitorID: String
        let expVisitorID: String
        let expVisitorOverrides: String
        let emailSubmissionID: String
        let referralCode: String
        let marketingEmailOptOut: Bool
        let ignoreCountryCode: Bool
    }

    struct ErrorResponse: Codable {
        let error: String
    }

    func createOktaAccount(
        email: String,
        firstname: String,
        password: String,
        marketingEmailOptOut: Bool
    ) {
        var request = URLRequest(url: NeevaConstants.createOktaAccountURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let salt = generateSalt()
        let salt_and_password = salt + password

        let saltAndPasswordData = Data(salt_and_password.utf8)
        let hashedSaltAndPassword = SHA512.hash(data: saltAndPasswordData)

        let hashedSaltAndPasswordEncoded = Data(hashedSaltAndPassword).base64EncodedString()

        guard let saltEncoded = salt.data(using: .utf8)?.base64EncodedString()
        else { return }

        let requestBody = OktaAccountRequestBodyModel(
            email: email,
            firstname: firstname.isEmpty ? "Member" : firstname,
            lastname: "",
            password: hashedSaltAndPasswordEncoded,
            salt: saltEncoded,
            visitorID: "",
            expVisitorID: "",
            expVisitorOverrides: "",
            emailSubmissionID: "",
            referralCode: "",
            marketingEmailOptOut: marketingEmailOptOut,
            ignoreCountryCode: true
        )
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            Logger.browser.error(
                "Error decoding request body for create okta account")
            return
        }

        request.httpBody = jsonData

        let config = URLSessionConfiguration.default
        let delegate = OktaAccountCreatedDelegate(introViewController: self)

        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

        session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 400 {
                    if let data = data {
                        var errorMsg = "Some unknown error occurred"
                        do {
                            let res = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            switch res.error {
                            case "UsedEmail":
                                errorMsg = "This email is associated with an existing Neeva account"
                                break
                            case "InternalError":
                                errorMsg = "Unexpected error occurred"
                                break
                            case "InvalidEmail":
                                errorMsg = "Invalid email used to register"
                                break
                            case "InvalidRequest":
                                errorMsg = "Invalid name and/or password"
                                break
                            case "InvalidToken":
                                errorMsg = "Token has already been used"
                                break
                            case "UsedToken":
                                errorMsg = "Token has already been used"
                                break
                            default:
                                errorMsg = res.error
                            }
                        } catch let err {
                            Logger.browser.error(
                                "Error creating Okta account: \(String(describing: err))")
                        }

                        DispatchQueue.main.async {
                            self.showErrorAlert(errMsg: errorMsg)
                        }
                    }
                }
            }
        }.resume()
    }

    func generateSalt() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let salt = String((0..<12).map { _ in letters.randomElement()! })
        return salt
    }
}

class OktaAccountCreatedDelegate: NSObject, URLSessionTaskDelegate {
    var introViewController: IntroViewController

    init(introViewController: IntroViewController) {
        self.introViewController = introViewController
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        if let cookie = response.allHeaderFields["Set-Cookie"] as? String {
            guard
                let token = cookie.split(
                    separator: ";"
                ).first?.replacingOccurrences(
                    of: "httpd~login=", with: ""
                )
            else { return }

            DispatchQueue.main.async {
                self.introViewController.didFinishClosure?(.oktaAccountCreated(token))
            }
        }
    }
}
