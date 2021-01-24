//
//  VenueExploreResource.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

struct VenueExploreResource: Resource {
    let lat: Double
    let lon: Double
    let radius: Int

    let path: String = "/v2/venues/explore"
    let method: Network.Method = .get

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "ll", value: [lat.description, lon.description].joined(separator: ",")),
            URLQueryItem(name: "radius", value: radius.description)
        ]
    }
}
