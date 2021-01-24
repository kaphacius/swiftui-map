//
//  FSResponse.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

struct FSResponse<T: Decodable>: Decodable {
    let meta: Meta
    let response: T

    struct Meta: Decodable {
        let code: Int
        let requestId: String
    }
}
