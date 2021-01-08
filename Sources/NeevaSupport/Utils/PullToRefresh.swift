//
//  PullToRefresh.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//  Inspired by SwiftUIRefresh:
//  https://github.com/siteline/SwiftUIRefresh/blob/fa8fac7b5eb5c729983a8bef65f094b5e0d12014/Sources/PullToRefresh.swift
//

import SwiftUI
import Introspect
import Apollo
import Combine

fileprivate let refreshActionID = UIAction.Identifier("co.neeva.refreshControl.action")

fileprivate struct StorageView<Content: View, Query: GraphQLQuery, Data>: View {
    let content: Content
    let controller: QueryController<Query, Data>

    @State var storage: Set<AnyCancellable> = []
    var body: some View {
        content.introspectTableView { tableView in
            if tableView.refreshControl == nil {
                tableView.refreshControl = UIRefreshControl()
                tableView.refreshControl!.addAction(UIAction(title: "Refresh", identifier: refreshActionID) { _ in
                    tableView.refreshControl!.beginRefreshing()
                    controller.reload()
                }, for: .valueChanged)

                controller.$running
                    .receive(on: RunLoop.main)
                    .sink { shouldBeRefreshing in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(200))) {
                            if let rc = tableView.refreshControl,
                               rc.isRefreshing != shouldBeRefreshing {
                                if shouldBeRefreshing {
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

extension View {
    func refreshControl<Query, Data>(refreshing controller: QueryController<Query, Data>) -> some View {
        StorageView(content: self, controller: controller)
    }
}
