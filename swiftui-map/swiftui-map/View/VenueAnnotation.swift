//
//  VenueAnnotation.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import SwiftUI

struct VenueAnnotation: View {
    let vm: VenueAnnotationVM
    @State var scale: CGFloat = 0.0

    var body: some View {
        Image(uiImage: vm.image.withRenderingMode(.alwaysTemplate))
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
            .background(Rectangle().foregroundColor(.gray))
            .clipShape(Circle())
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1.5)
            ).shadow(color: .primary, radius: 3.0)
            .scaleEffect(scale)
            .onAppear(perform: self.onAppear)
            .onDisappear {
                self.scale = 0.0
            }
    }

    func onAppear() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(randomDelay * 100)
            ) {
                withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: 200.0,
                                damping: 10,
                                initialVelocity: 20
                )) {
                    self.scale = 1.0
                }
            }
    }

    var randomDelay: Int {
        Int.random(in: 0..<3)
    }
}

#if DEBUG
import CoreLocation

extension VenueAnnotationVM {
    init() {
        self.id = "foo"
        self.loc = CLLocationCoordinate2D()
        self.name = "Bar"
        self.image = UIImage(systemName: "leaf.fill")!
        self.categoryName = "Parks"
        self.address = ["First line", "Second line", "Third line"]
    }
}

struct VenueAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        VenueAnnotation(vm: VenueAnnotationVM())
    }
}
#endif
