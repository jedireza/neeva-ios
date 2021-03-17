import UIKit
import NeevaSupport
import KeychainAccess

fileprivate let servers = ["m1.neeva.co", "alpha.neeva.co", "example.com"]

class UserInfoViewController: UIViewController {

    @IBOutlet weak var tokenInput: UITextField!
    @IBOutlet weak var dataOutput: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var serverPicker: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenInput.text = try? NeevaConstants.keychain.getString(NeevaConstants.loginKeychainKey)
        if let idx = servers.firstIndex(of: NeevaConstants.appHost) {
            serverPicker.selectedSegmentIndex = idx
        }
    }

    @IBAction func serverDidChange() {
        NeevaConstants.appHost = servers[serverPicker.selectedSegmentIndex]
        tokenInput.text = try? NeevaConstants.keychain.getString( NeevaConstants.loginKeychainKey)
        runUserQuery()
    }
    @IBAction func runUserQuery() {
        tokenInput.resignFirstResponder()
        try? NeevaConstants.keychain.set(tokenInput.text!, key: NeevaConstants.loginKeychainKey)
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.4) {
            self.activityIndicator.alpha = 1
        }
        UserInfoQuery().fetch { result in
            self.activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.4) {
                self.activityIndicator.alpha = 0
            }
            switch result {
            case .success(let data):
                if let user = data.user {
                    self.dataOutput.text = "Hello, \(user.profile.displayName)!\n" + String(
                        data: try! JSONSerialization.data(withJSONObject: user.jsonObject, options: [.prettyPrinted, .sortedKeys]),
                        encoding: .utf8
                    )!
                } 
            case .failure(let error):
                if let errors = (error as? GraphQLAPI.Error)?.errors {
                    let messages = errors.filter({ $0.message != nil }).map({ $0.message! })
                    self.dataOutput.text = "ERROR:\n\(messages.joined(separator: "\n"))"
                } else {
                    print(error)
                }
            }
        }
    }
}

