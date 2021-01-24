//
//  VenueAnnotation.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import SwiftUI

struct VenueAnnotation: View {
    let vm: VenueAnnotationVM

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
