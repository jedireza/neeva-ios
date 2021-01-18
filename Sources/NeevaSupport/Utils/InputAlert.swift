//
//  InputAlert.swift
//  
//
//  Created by Jed Fox on 1/8/21.
//

import SwiftUI

/// Open an alert box with a text input field.
/// - Parameters:
///   - title: the title to display in the alert
///   - confirmationButtonTitle: the label of the button that will cause `onConfirm` to be called
///   - inputRequired: whether to prevent the alert from being confirmed with empty text
///   - initialText: the text to display in the text field when the alert first opens
///   - placeholder: placeholder text to display when the text field is empty
///   - configureTextField: a function to update the style of the text field (ie return key type, clear button, etc)
///   - onConfirm: called with the content of the text field when the return key is pressed or the confirmation button is tapped
func openTextInputAlert(
    title: String, confirmationButtonTitle: String,
    inputRequired: Bool = true, initialText: String = "", placeholder: String? = nil,
    configureTextField: ((UITextField) -> ())? = nil,
    onConfirm: @escaping (String) -> ()
) {
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    alert.addAction(.init(title: "Cancel", style: .cancel))
    let confirmAction = UIAlertAction(title: confirmationButtonTitle, style: .default) { _ in
        onConfirm(alert.textFields!.first!.text!)
    }
    if inputRequired {
        confirmAction.isEnabled = false
    }
    alert.addAction(confirmAction)
    alert.preferredAction = confirmAction

    alert.addTextField { tf in
        tf.text = initialText
        tf.placeholder = placeholder
        tf.enablesReturnKeyAutomatically = inputRequired
        if inputRequired {
            tf.addAction(UIAction { _ in
                confirmAction.isEnabled = tf.hasText
            }, for: .editingChanged)
        }
        configureTextField?(tf)
    }
    UIApplication.shared.frontViewController.present(alert, animated: true, completion: nil)
}
