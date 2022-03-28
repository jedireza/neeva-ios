// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import Shared

struct PlaceView: View {
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
