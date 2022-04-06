// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SiteRowView: View {
    let site: Site

    var body: some View {
        Group {
            HStack {
                FaviconView(forSite: site)
                    .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)

                VStack(alignment: .leading) {
                    Text(site.displayTitle)
                    Text(site.url.absoluteString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }.lineLimit(1)

                Spacer()
            }
            .padding()
            .background(Color.DefaultBackground)
        }.padding(.horizontal)
    }
}

enum TimeSection: Int, CaseIterable {
    case today
    case yesterday
    case lastWeek
    case lastMonth

    static let count = 5

    var title: String? {
        switch self {
        case .today:
            return Strings.TableDateSectionTitleToday
        case .yesterday:
            return Strings.TableDateSectionTitleYesterday
        case .lastWeek:
            return Strings.TableDateSectionTitleLastWeek
        case .lastMonth:
            return Strings.TableDateSectionTitleLastMonth
        }
    }
}

struct HistorySectionHeader: View {
    let section: TimeSection

    var title: some View {
        HStack {
            Text(section.title ?? "")
                .fontWeight(.medium)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
        .padding(.vertical, 8)
    }

    var body: some View {
        title.background(Color.groupedBackground)
    }
}

struct HistoryPanelView: View {
    @ObservedObject var model: HistoryPanelModel

    let onDismiss: () -> Void

    var historyList: some View {
        ScrollView {
            // Recently closed tabs and clear history
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    GroupedRowButtonView(label: "Clear Recent History", symbol: .trash) {

                    }

                    Color.groupedBackground.frame(height: 1)

                    GroupedRowButtonView(
                        label: "Recently Closed Tabs", symbol: .clockArrowCirclepath
                    ) {

                    }
                }.accentColor(.label)
            }.padding(.horizontal)

            // History List
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(TimeSection.allCases, id: \.self) { section in
                    let itemsInSection = model.groupedSites.itemsForSection(section.rawValue)

                    if itemsInSection.count > 0 {
                        Section(header: HistorySectionHeader(section: section)) {
                            ForEach(
                                Array(itemsInSection.enumerated()), id: \.element
                            ) { index, site in
                                SiteRowView(site: site)
                                    .onAppear {
                                        model.loadNextItemsIfNeeded(from: index)
                                    }

                                Color.groupedBackground.frame(height: 1)
                            }
                        }
                    }
                }
            }.padding(.top, 20)
        }.background(Color.groupedBackground.ignoresSafeArea(.container))
    }

    @ViewBuilder
    var content: some View {
        if model.groupedSites.isEmpty {
            Text("Websites you've visted\nrecently will show up here.")
                .multilineTextAlignment(.center)
        } else {
            if #available(iOS 15.0, *) {
                historyList.refreshable {
                    model.reloadData()
                }
            } else {
                historyList
            }
        }
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        onDismiss()
                    } label: {
                        Text("Done")
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            model.reloadData()
        }
    }
}
