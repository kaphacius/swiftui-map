//
//  VenueExploreResponse.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

struct VenueExploreResponse: Decodable {
    let groups: Array<Group>

    struct Group: Decodable {
        let items: Array<Item>

        struct Item: Decodable {
            let venue: Venue
        }
    }
}
