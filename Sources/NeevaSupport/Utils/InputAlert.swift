//
//  InputAlert.swift
//  
//
//  Created by Jed Fox on 1/8/21.
//

import SwiftUI

func openTextInputAlert(
    title: String, confirmationButtonTitle: String,
    inputRequired: Bool = true, initialText: String = "", placeholder: String? = nil,
    configureTextField: ((UITextField) -> ())?,
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
