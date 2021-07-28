// Copyright Neeva. All rights reserved.

// Inspired by SwiftUIRefresh:
// https://github.com/siteline/SwiftUIRefresh/blob/fa8fac7b5eb5c729983a8bef65f094b5e0d12014/Sources/PullToRefresh.swift

import Apollo
import Combine
import Introspect
import Shared
import SwiftUI

extension View {
    /// Add a refresh control to the nearest `List`.
    /// - Parameter controller: the `QueryController` to refresh when the refresh control is activated
    func refreshControl<Query, Data>(refreshing controller: QueryController<Query, Data>)
        -> some View
    {
        StorageView(content: self, controller: controller)
    }
}

private let refreshActionID = UIAction.Identifier("co.neeva.refreshControl.action")

private struct StorageView<Content: View, Query: GraphQLQuery, Data>: View {
    let content: Content
    let controller: QueryController<Query, Data>

    @State var storage: Set<AnyCancellable> = []
    var body: some View {
        // NB: this should be fairly easy to convert to work with scroll views as well, we just need
        //     to specify at the call site which type of view we're looking for.
        content.introspectTableView { tableView in
            if tableView.refreshControl == nil {
                tableView.refreshControl = UIRefreshControl()
                tableView.refreshControl!.addAction(
                    UIAction(title: "Refresh", identifier: refreshActionID) { _ in
                        tableView.refreshControl!.beginRefreshing()
                        controller.reload()
                    }, for: .valueChanged)

                controller.$state
                    .receive(on: RunLoop.main)
                    .sink { state in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                            if let rc = tableView.refreshControl,
                                rc.isRefreshing != state.isRunning
                            {
                                if state.isRunning {
                                    rc.beginRefreshing()
                                } else {
                                    rc.endRefreshing()
                                }
                            }
                        }
                    }.store(in: &storage)
            }
        }
    }
}
