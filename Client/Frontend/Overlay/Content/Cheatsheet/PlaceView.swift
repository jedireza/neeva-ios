// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import MapKit
import SwiftUI
import Shared

private struct PlaceAnnotation: Identifiable {
    typealias ID = String

    let lat: Double
    let lon: Double
    let address: String

    var id: String {
        address
    }

    init(from place: Place) {
        self.lat = place.position.lat
        self.lon = place.position.lon
        self.address = place.address.full
    }
}

struct PlaceView: View {
    @State private var mapRegion: MKCoordinateRegion

    let place: Place
    private let annotatedMapItems: [PlaceAnnotation]

    let mapHeight: CGFloat = 200
    let mapSpanMeters: CLLocationDistance = 500

    init(place: Place) {
        _mapRegion = State(
            wrappedValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.position.lat, longitude: place.position.lon),
                latitudinalMeters: mapSpanMeters,
                longitudinalMeters: mapSpanMeters
            )
        )
        annotatedMapItems = [PlaceAnnotation(from: place)]
        self.place = place
    }

    var body: some View {
        GeometryReader { geometry in
            Map(
                coordinateRegion: $mapRegion,
                interactionModes: .zoom,
                showsUserLocation: true,
                userTrackingMode: nil,
                annotationItems: annotatedMapItems
            ) { place in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon),
                    tint: Color.brand.variant.red
                )
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .frame(height: mapHeight)
        VStack(alignment: .leading) {
            Text(place.name)
                .withFont(.headingLarge)
                .foregroundColor(.label)
        }
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
