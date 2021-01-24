//
//  VenueDetailsView.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import SwiftUI

struct VenueDetailsView: View {
    let vm: VenueAnnotationVM
    var body: some View {
        VStack() {
            Text(vm.categoryName)
                .font(.title2)
            header
            address
            Spacer()
        }.padding()
    }

    var header: some View {
        HStack {
            Image(uiImage: vm.image.withRenderingMode(.alwaysTemplate))
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: 80, height: 80)
                .padding()
            Text(vm.name)
                .font(.title)
            Spacer()
        }
    }

    var address: some View {
        HStack {
            VStack(alignment: .leading) {
                ForEach(vm.address, id: \.self) { line in
                    Text(line)
                }.padding(.bottom, 5.0)
                .font(.title3)
            }
            Spacer()
        }
    }
}

#if DEBUG
struct VenueDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VenueDetailsView(vm: VenueAnnotationVM())
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
#endif
