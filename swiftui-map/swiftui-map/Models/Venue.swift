//
//  Venue.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

struct Venue: Decodable {
    enum Errors: Error {
        case primaryCategoryMissing
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case lat
        case lon = "lng"
        case formattedAddress
        case categories
        case icon
        case prefix
    }

    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let formattedAddress: [String]
    let category: Category

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)

        let lc = try c.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        lat = try lc.decode(Double.self, forKey: .lat)
        lon = try lc.decode(Double.self, forKey: .lon)
        formattedAddress = try lc.decode(Array<String>.self, forKey: .formattedAddress)

        let categories = try c.decode([Category].self, forKey: .categories)
        guard let primary = categories.first(where: \.primary) else {
            throw Errors.primaryCategoryMissing
        }

        category = primary
    }
}

extension Venue: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Venue {
    struct Category: Decodable, Hashable {
        enum CodingKeys: String, CodingKey {
            case id
            case icon
            case iconPrefix = "prefix"
            case iconSuffix = "suffix"
            case pluralName
            case primary
        }

        let id: String
        let iconPrefix: String
        let iconSuffix: String
        let pluralName: String
        let primary: Bool

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decode(String.self, forKey: .id)
            pluralName = try c.decode(String.self, forKey: .pluralName)
            primary = try c.decode(Bool.self, forKey: .primary)

            let ic = try c.nestedContainer(keyedBy: CodingKeys.self, forKey: .icon)
            iconPrefix = try ic.decode(String.self, forKey: .iconPrefix)
            iconSuffix = try ic.decode(String.self, forKey: .iconSuffix)
        }
    }
}
