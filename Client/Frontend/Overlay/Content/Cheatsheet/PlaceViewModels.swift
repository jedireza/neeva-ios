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

struct LocalizedOperatingHour {
    let start: String
    let end: String
    let weekday: String
    let gregorianWeekday: Int
}

class PlaceViewModel: ObservableObject {
    @Published var mapRegion: MKCoordinateRegion

    static let geocoder = CLGeocoder()
    // Dummy date for formatting use
    static let dummyDate = Date()
    static let inputTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // 24h clock
        formatter.dateFormat = "HHmm"
        return formatter
    }()
    static let timeLocalizedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()

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

    // Gregorian Day of the Week (Sunday is 1, Saturday is 7)
    var currentDayOfTheWeek: Int? {
        return Calendar(identifier: .gregorian).dateComponents([.weekday], from: Date()).weekday
    }
    var sortedLocalizedHours: [LocalizedOperatingHour]?

    init(_ place: Place) {
        print("init")
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

        if let hours = place.hours {
            self.sortedLocalizedHours = Self.sortAndFormatOperatingHour(from: hours)
        }
    }

    class func sortAndFormatOperatingHour(from hours: [Place.Hour]) -> [LocalizedOperatingHour] {
        hours.map { hour -> (LocalizedOperatingHour, Int) in
            // Parse time of day
            let start = Self.inputTimeFormatter.date(from: hour.start)!
            let end = Self.inputTimeFormatter.date(from: hour.end)!

            // put the days from API response into gregorian calendar
            // yelp uses 0 through 6 for monday through sunday
            // Calendar.gregorian uses 1 through 7 for sunday through saturday
            let gregorianWeekday = (hour.day + 1) % 7 + 1

            // find weekday in current local
            var calendar = Calendar.current
            calendar.locale = Locale.current
            let weekday = (gregorianWeekday + 7 - calendar.firstWeekday) % 7 + 1

            let hour = LocalizedOperatingHour(
                start: Self.timeLocalizedFormatter.string(from: start),
                end: Self.timeLocalizedFormatter.string(from: end),
                // in English in Gregrorian, the symols are ["Sun", "Mon", ...]
                weekday: calendar.shortWeekdaySymbols[weekday - 1],
                gregorianWeekday: gregorianWeekday
            )

            return (hour, weekday)
        }.sorted {
            $0.1 < $1.1
        }.map {
            $0.0
        }
    }
}
