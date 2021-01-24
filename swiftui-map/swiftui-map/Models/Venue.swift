//
//  Venue.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

struct Venue: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case lat
        case lon = "lng"
        case formattedAddress
    }

    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let formattedAddress: [String]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)

        let lc = try c.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        lat = try lc.decode(Double.self, forKey: .lat)
        lon = try lc.decode(Double.self, forKey: .lon)
        formattedAddress = try lc.decode(Array<String>.self, forKey: .formattedAddress)
    }
}
