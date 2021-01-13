//
//  SearchBar.swift
//  
//
//  Created by Jed Fox on 1/13/21.
//  Adapted from https://github.com/stleamist/NavigationSearchBarModifier/blob/f1d92c7e/Sources/NavigationSearchBarModifier/NavigationSearchBarModifier.swift
//

import SwiftUI

extension View {
    public func searchBar(_ placeholder: String, text: Binding<String?>) -> some View {
        background(SearchBar(placeholder: placeholder, text: text))
    }
}

fileprivate struct SearchBar: UIViewControllerRepresentable {
    let placeholder: String
    @Binding var text: String?

    func makeUIViewController(context: Context) -> ViewController {
        ViewController(text: $text, placeholder: placeholder)
    }

    func updateUIViewController(_ vc: ViewController, context: Context) {
        vc.text = $text
        vc.placeholder = placeholder
    }

    class ViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

        var text: Binding<String?>
        var placeholder: String {
            didSet {
                searchController.searchBar.placeholder = placeholder
            }
        }
        let searchController = UISearchController()

        init(text: Binding<String?>, placeholder: String) {
            self.text = text
            self.placeholder = placeholder
            super.init(nibName: nil, bundle: nil)
            setupSearchController()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMove(toParent parent: UIViewController?) {
            parent?.navigationItem.searchController = searchController
            parent?.navigationItem.hidesSearchBarWhenScrolling = false
        }

        private func setupSearchController() {
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = self

            searchController.searchBar.searchBarStyle = .prominent
            searchController.obscuresBackgroundDuringPresentation = false
        }

        func didPresentSearchController(_ searchController: UISearchController) {
            text.wrappedValue = ""
        }

        func didDismissSearchController(_ searchController: UISearchController) {
            text.wrappedValue = nil
        }

        // UISearchResultsUpdating
        func updateSearchResults(for searchController: UISearchController) {
            if let newText = searchController.searchBar.text,
               text.wrappedValue != newText {
                text.wrappedValue = newText
            }
        }
    }
}
