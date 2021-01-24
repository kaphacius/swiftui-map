//
//  SwiftUI_MapApp.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import SwiftUI

@main
struct SwiftUI_MapApp: App {
    let network: Network = {
        let apiVersion = "20210124"

        #error("Insert your client_id and client_secret here. They be obtained at https://foursquare.com/developers/apps")

        let fsStatic = [
            URLQueryItem(name: "client_id", value: <#T##String#>),
            URLQueryItem(name: "client_secret", value: <#T##String#>),
            URLQueryItem(name: "v", value: apiVersion)
        ]

        return Network(
            host: URL(string: "api.foursquare.com")!,
            scheme: .https,
            staticQuery: fsStatic
        )
    }()

    var body: some Scene {
        WindowGroup {
            MapView(vm: MapVM(network: network))
        }
    }
}
