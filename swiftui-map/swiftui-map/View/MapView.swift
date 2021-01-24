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
                        VenueAnnotation(vm: venueVM)
                            .onTapGesture {
                                vm.selectedAnnotation = venueVM
                            }
                    })
                }
            ).animation(.easeIn(duration: 0.1))
            .edgesIgnoringSafeArea(.all)
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
        ).alert(isPresented: $vm.showingAlert) { errorAlert }
        .sheet(
            item: $vm.selectedAnnotation,
            onDismiss: nil,
            content: { venueVM in
                Text(venueVM.name)
                    .frame(idealWidth: 0, idealHeight: 0)
            })
    }

    var errorAlert: Alert {
        Alert(
            title: Text("Error"),
            message: Text(vm.errorMessage),
            dismissButton: .default(Text("OK"))
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
