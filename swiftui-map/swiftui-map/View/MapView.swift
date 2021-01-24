//
//  MapView.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var vm: MapVM

    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $vm.mapRegion,
                showsUserLocation: true,
                annotationItems: vm.venues,
                annotationContent: { venueVM in
                    MapAnnotation(coordinate: venueVM.loc, content: {
                        Circle()
                            .foregroundColor(.yellow)
                            .frame(width: 25.0, height: 25.0)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 10.0)
                    })
                }
            ).animation(.easeIn(duration: 0.1))
        }.overlay(
            VStack {
                Slider(value: sliderBinding, in: 100.0...2000.0, step: 5)
                Text("Search radius \(vm.radius) m")
            }.padding(10.0)
            .background(RoundedRectangle(cornerRadius: 5.0)
                            .foregroundColor(Color.blue.opacity(0.5)))
            .padding(10.0)
            .padding(.bottom, 20.0),
            alignment: .bottom
        )
    }

    var sliderBinding: Binding<Double> {
        Binding(get: {
            Double(vm.radius)
        }, set: { newValue in
            vm.radius = Int(newValue)
        })
    }
}
