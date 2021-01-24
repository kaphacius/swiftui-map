//
//  Network.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation
import Combine

enum NError: Error {
    case URLError(Error)
    case parsingError
    case urlBuildFailed
}

typealias NResult<T> = Result<T, Error>
typealias NPublisher<T> = AnyPublisher<NResult<T>, Never>
typealias NJust<T> = Just<NResult<T>>

class Network {
    private let host: URL
    private let scheme: Scheme
    private let staticQuery: [URLQueryItem]

    init(
        host: URL,
        scheme: Scheme = .http,
        staticQuery: [URLQueryItem] = []
    ) {
        self.host = host
        self.scheme = scheme
        self.staticQuery = staticQuery
    }

    private func buildRequest(resource r: Resource) -> URLRequest? {
        r.buildUrlRequest(scheme: scheme, host: host.absoluteString, staticQuery: staticQuery)
    }

    func load<T>(resource r: Resource) -> NPublisher<T> where T : Decodable {
        guard let request = buildRequest(resource: r) else {
            return Just<NResult<T>>(.failure(NError.urlBuildFailed)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .map(Result.success)
            .catch { NJust<T>(.failure(NError.URLError($0))).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
}

extension Network {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }

    enum Scheme: String {
        case http = "http"
        case https = "https"
    }
}

