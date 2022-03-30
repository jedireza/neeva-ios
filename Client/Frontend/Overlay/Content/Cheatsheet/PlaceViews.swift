// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import MapKit
import SwiftUI
import Shared

private struct RatingsView: View {
    private struct StarView: View {
        let fill: Double

        var body: some View {
            switch fill {
            case 0:
                Image(systemSymbol: .star)
                    .renderingMode(.template)
            case 0..<1:
                Image(systemSymbol: .starLeadinghalfFill)
                    .renderingMode(.template)
            case 1...:
                Image(systemSymbol: .starFill)
                    .renderingMode(.template)
            default:
                EmptyView()
            }
        }
    }

    let rating: Double

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            StarView(fill: max(min(1, rating), 0))
            StarView(fill: max(min(1, rating - 1), 0))
            StarView(fill: max(min(1, rating - 2), 0))
            StarView(fill: max(min(1, rating - 3), 0))
            StarView(fill: max(min(1, rating - 4), 0))
        }
        .foregroundColor(Color.brand.orange)
        .font(.system(size: 12))
    }
}

private struct QuickActionButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat = 10
    let padding: CGFloat = 7

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .foregroundColor(.accentColor)
                .padding(padding)
            Spacer()
        }
        .background(
            Color.secondaryBackground
                .cornerRadius(cornerRadius)
        )
        .overlay(
            Color.white
                .cornerRadius(cornerRadius)
                .opacity(configuration.isPressed ? 0.2 : 0)
        )

    }
}

struct PlaceView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    @StateObject private var viewModel: PlaceViewModel

    @State private var hourExpanded: Bool = false
    @State private var addressExpanded: Bool = false

    let mapHeight: CGFloat = 200

    var place: Place {
        viewModel.place
    }
    var categories: String? {
        let joined = place.categories.joined(separator: ", ")
        return !joined.isEmpty ? joined : nil
    }
    var subTitles: [Text] {
        var texts: [Text] = []
        if let categories = categories {
            texts.append(
                Text(categories)
                    .foregroundColor(.secondaryLabel)
            )
        }
        if let operatingStatus = place.articulatedOperatingStatus {
            if categories != nil {
                texts.append(
                    Text(" · ")
                )
            }
            texts.append(
                Text(operatingStatus)
                    .foregroundColor(place.isOpenNow ? .brand.green : .brand.red)
            )
            if let hour = place.articulatedHour {
                texts += [
                    Text(" "),
                    Text(hour)
                        .foregroundColor(.secondaryLabel)
                ]
            }
        }
        return texts
    }

    init(viewModel: PlaceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            Map(
                coordinateRegion: $viewModel.mapRegion,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: nil,
                annotationItems: viewModel.annotatedMapItems
            ) { place in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon),
                    tint: Color.brand.variant.red
                )
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: mapHeight)
        VStack(alignment: .leading, spacing: 5) {
            Text(place.name)
                .withFont(.headingXLarge)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.label)

            subTitle
                .withFont(unkerned: .bodyMedium)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            ratings

            quickActions

            detailsSection
        }
    }

    @ViewBuilder
    var subTitle: some View {
        let texts = subTitles
        if texts.isEmpty {
            EmptyView()
        } else {
            texts.reduce(Text(""), +)
        }
    }

    @ViewBuilder
    var ratings: some View {
        HStack(alignment: .center) {
            // rating is out of 5
            if let rating = place.rating {
                RatingsView(rating: rating)
            }

            if let reviews = place.reviewCount {
                Text("\(reviews) Reviews")
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
            }

            if let price = place.price {
                Text(price)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    var quickActions: some View {
        HStack(spacing: 5) {
            if let phone = place.telephone ?? place.telephonePretty {
                Button(action: {
                    if let url = URL(string: "tel://\(phone)"),
                       UIApplication.shared.canOpenURL(url) {
                      UIApplication.shared.open(url)
                    }
                }, label: {
                    VStack {
                        Image(systemSymbol: .phoneFill)
                        Text("Call")
                            .withFont(.bodyMedium)
                    }
                })
                .buttonStyle(QuickActionButtonStyle())
            }

            if let website = place.websiteURL {
                Button(action: {
                    onOpenURLForCheatsheet(website, "PlaceViewQuickActionWebsite")
                }, label: {
                    VStack {
                        Image(systemSymbol: .globe)
                        Text("Website")
                            .withFont(.bodyMedium)
                    }
                })
                .buttonStyle(QuickActionButtonStyle())
            }

            if let yelpLink = place.yelpURL {
                Button(action: {
                    onOpenURLForCheatsheet(yelpLink, "PlaceViewQuickActionYelp")
                }, label: {
                    VStack {
                        Image(systemSymbol: .globe)
                        Text("Yelp")
                            .withFont(.bodyMedium)
                    }
                })
                .buttonStyle(QuickActionButtonStyle())
            }

            Button(action: {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: viewModel.placeMark))
                mapItem.name = place.name
                mapItem.openInMaps()
            }, label: {
                VStack {
                    Image(systemSymbol: .arrowTriangleTurnUpRightDiamondFill)
                    Text("Directions")
                        .withFont(.bodyMedium)
                        .lineLimit(1)
                }
            })
            .buttonStyle(QuickActionButtonStyle())
        }
    }

    @ViewBuilder
    var detailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Operating Hour
            if let hours = viewModel.sortedLocalizedHours,
               let nextOpen = viewModel.nextOpen
            {
                VStack(alignment: .leading , spacing: 0) {
                    HStack(alignment: .center) {
                        Text("Hours")
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                        if place.isOpenNow {
                            Text("Open")
                                .withFont(.headingMedium, weight: .semibold)
                                .foregroundColor(.brand.green)
                        } else {
                            Text("Closed Today")
                                .withFont(.headingMedium, weight: .semibold)
                                .foregroundColor(.brand.red)
                        }
                        Spacer()
                        Button(action: {
                            hourExpanded.toggle()
                        }, label: {
                            if hourExpanded {
                                Image(systemSymbol: .chevronUp)
                                    .foregroundColor(.label)
                            } else {
                                Image(systemSymbol: .chevronDown)
                                    .foregroundColor(.label)
                            }
                        })
                        .padding(.horizontal)
                    }

                    Group {
                        if !hourExpanded {
                            HStack {
                                if case let .open(start, end) = nextOpen.articulatedHours{
                                    if nextOpen.gregorianWeekday != viewModel.currentDayOfTheWeek {
                                        Text(nextOpen.weekday)
                                            .withFont(.bodyMedium)
                                            .foregroundColor(.label)
                                    }
                                    Text("\(start) - \(end)")
                                        .withFont(.bodyMedium)
                                        .foregroundColor(.label)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(hours, id: \.gregorianWeekday) { hour in
                                    HStack {
                                        Text(hour.weekday)
                                            .withFont(.bodyMedium)
                                        Spacer()
                                        switch hour.articulatedHours {
                                        case .open(let start, let end):
                                            Text("\(start) - \(end)")
                                                .withFont(.bodyMedium)
                                        case .closed:
                                            Text("Closed")
                                                .withFont(.bodyMedium)
                                        }
                                    }
                                    .foregroundColor(.label)
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }

                Divider()
                    .padding(.vertical, 7)
            }

            // Address Section
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text("Address")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                    Spacer()
                    Button(action: {
                        addressExpanded.toggle()
                    }, label: {
                        if addressExpanded {
                            Image(systemSymbol: .chevronUp)
                                .foregroundColor(.label)
                        } else {
                            Image(systemSymbol: .chevronDown)
                                .foregroundColor(.label)
                        }
                    })
                    .padding(.horizontal)
                }
                Group {
                    if !addressExpanded {
                        Text(place.address.street)
                            .withFont(.bodyMedium)
                    } else {
                        let separated = place.address.full.components(separatedBy: ", ")
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(
                                separated.indices,
                                id: \.self
                            ) { idx in
                                Text(separated[idx])
                                    .withFont(.bodyMedium)
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = addressExpanded ? place.address.full : place.address.street
                }, label: {
                    Text("Copy to clipboard")
                    Image(systemName: "doc.on.doc")
                })
            }

            // Phone number
            if let phone = place.telephonePretty ?? place.telephone {
                Divider()
                    .padding(.vertical, 7)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Phone")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                    Button(action: {
                        if let url = URL(string: "tel://\(phone)"),
                           UIApplication.shared.canOpenURL(url) {
                          UIApplication.shared.open(url)
                        }
                    }, label: {
                        HStack {
                            Text(phone)
                                .withFont(.bodyMedium)
                            Spacer()
                        }
                    })
                }
            }
        }
        .padding()
        .background(
            Color.secondaryBackground
                .cornerRadius(10)
        )
    }
}

struct PlaceInlineView: View {
    let place: Place

    var body: some View {
        VStack {
            Group {
                Text(place.name)
                Text(place.price ?? "no price")
                Text(String(place.rating ?? 0))
                Text(String(place.reviewCount ?? 0))
            }
            Group {
                Text(place.address.full)
                Text(place.address.street)
                Text(String(place.position.lon))
                Text(String(place.position.lat))
            }
            Group {
                Text(place.telephone ?? "no tele")
                Text(place.telephonePretty ?? "no pretty tele")
            }
            Group {
                Text(place.articulatedOperatingStatus ?? "no art oper status")
                Text(place.articulatedHour ?? "no art hour")
                if let specialHours = place.specialHours {
                    ForEach(specialHours, id: \.date) { hour in
                        VStack {
                            Text(String(hour.isOvernight))
                            Text(String(hour.isClosed))
                            Text(String(hour.start))
                            Text(String(hour.end))
                            Text(String(hour.date))
                        }
                    }
                }
                if let hours = place.hours {
                    ForEach(hours, id: \.day) { hour in
                        Text(String(hour.isOvernight))
                        Text(String(hour.start))
                        Text(String(hour.end))
                        Text(String(hour.day))
                    }
                }
            }
            Group {
                Text(place.websiteURL?.absoluteString ?? "no website url")
                Text(place.yelpURL?.absoluteString ?? "no yelp url")
                Text(place.yelpURL?.absoluteString ?? "no image url")
            }
            Group {
                Text(place.mapImage?.url?.absoluteString ?? "no map image url")
                Text(place.mapImageLarge?.url?.absoluteString ?? "no large map image url")
            }
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
