//
//  Resource.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

protocol Resource {
    var queryItems: [URLQueryItem] { get }
    var method: Network.Method { get }
    var path: String { get }
    var body: Data? { get }
}

extension Resource {
    var queryItems: [URLQueryItem] { [] }
    var body: Data? { nil }

    func buildUrl(
        scheme: Network.Scheme,
        host: String,
        staticQuery: [URLQueryItem] = []
    ) -> URL? {
        var comps = URLComponents()
        comps.scheme = scheme.rawValue
        comps.host = host
        comps.path = path
        comps.queryItems = queryItems + staticQuery

        return comps.url
    }

    func buildUrlRequest(
        scheme: Network.Scheme,
        host: String,
        staticQuery: [URLQueryItem]
    ) -> URLRequest? {
        guard let url = buildUrl(
                scheme: scheme,
                host: host,
                staticQuery: staticQuery
        ) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        return request
    }
}
