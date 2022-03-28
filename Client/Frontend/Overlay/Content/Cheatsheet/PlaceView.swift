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
    let onTap: () -> Void

    var id: String {
        address
    }

    init(from place: Place, onTap: @escaping () -> Void ) {
        self.lat = place.position.lat
        self.lon = place.position.lon
        self.address = place.address.full
        self.onTap = onTap
    }
}

struct PlaceView: View {
    let place: Place

    @State private var mapRegion: MKCoordinateRegion
    private let annotatedMapItems: [PlaceAnnotation]

    init(place: Place) {
        _mapRegion = State(
            wrappedValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: place.position.lat, longitude: place.position.lon),
                latitudinalMeters: 200,
                longitudinalMeters: 200
            )
        )
        annotatedMapItems = [PlaceAnnotation(from: place, onTap: { print("tap!") })]
        self.place = place
    }

    var body: some View {
        Map(
            coordinateRegion: $mapRegion,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: nil,
            annotationItems: annotatedMapItems
        ) { place in
            MapAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon),
                anchorPoint: .zero
            ) {
                Circle()
                    .stroke(.red, lineWidth: 3)
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        place.onTap()
                    }
            }
        }
        .frame(width: 400, height: 400, alignment: .center)
        Text("im here!")
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
