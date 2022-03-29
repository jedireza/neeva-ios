// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import MapKit
import Shared
import SwiftUI

struct PlaceAnnotation: Identifiable {
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

class PlaceViewModel: ObservableObject {
    @Published var mapRegion: MKCoordinateRegion

    static let geocoder = CLGeocoder()

    let place: Place

    // Core Location Objects for Displaying and Opening Maps
    private var _placeMark: CLPlacemark?
    var placeMark: CLPlacemark {
        _placeMark ?? CLPlacemark(
            location: CLLocation(latitude: place.position.lat, longitude: place.position.lon),
            name: place.name,
            postalAddress: nil
        )
    }
    let annotatedMapItems: [PlaceAnnotation]

    // Constants
    let mapSpanMeters: CLLocationDistance = 500

    init(_ place: Place) {
        self.place = place

        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: place.position.lat, longitude: place.position.lon),
            latitudinalMeters: mapSpanMeters,
            longitudinalMeters: mapSpanMeters
        )
        annotatedMapItems = [PlaceAnnotation(from: place)]

        Self.geocoder.geocodeAddressString(place.address.full) { [self] placemarks, error in
            if let placemark = placemarks?.first {
                self._placeMark = CLPlacemark(
                    location: CLLocation(latitude: place.position.lat, longitude: place.position.lon),
                    name: place.name,
                    postalAddress: placemark.postalAddress
                )
            }
        }
    }
}
