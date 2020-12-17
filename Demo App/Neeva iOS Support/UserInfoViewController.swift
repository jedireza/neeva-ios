import UIKit
import NeevaSupport
import SwiftKeychainWrapper

class UserInfoViewController: UIViewController {

    @IBOutlet weak var tokenInput: UITextField!
    @IBOutlet weak var dataOutput: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenInput.text = KeychainWrapper.standard.string(forKey: NeevaConstants.loginKeychainKey)
    }

    @IBAction func runUserQuery(_ sender: Any) {
        KeychainWrapper.standard.set(tokenInput.text!, forKey: NeevaConstants.loginKeychainKey)
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.4) {
            self.activityIndicator.alpha = 1
        }
        GraphQLAPI.fetch(query: UserInfoQuery()) { result in
            self.activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.4) {
                self.activityIndicator.alpha = 0
            }
            switch result {
            case .success(let result):
                if let errors = result.errors, !errors.isEmpty {
                    let messages = errors.filter({ $0.message != nil }).map({ $0.message! })
                    self.dataOutput.text = "ERROR:\n\(messages.joined(separator: "\n"))"
                } else if let user = result.data?.user {
                    self.dataOutput.text = "Hello, \(user.profile.displayName)!\n" + String(
                        data: try! JSONSerialization.data(withJSONObject: user.jsonObject, options: [.prettyPrinted, .sortedKeys]),
                        encoding: .utf8
                    )!
                } 
            case .failure(let error):
                print(error)
            }
        }
    }
}

