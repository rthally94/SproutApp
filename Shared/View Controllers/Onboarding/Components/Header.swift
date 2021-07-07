//
//  Header.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct Header: View {
    var image: Image
    var title: Text
    var subtitle: Text?

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width/3)

                title
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)

                if let subtitle = subtitle {
                    subtitle
                        .multilineTextAlignment(.center)
                }
                Spacer()

                HStack {
                    Spacer()
                }
            }
        }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header(image: Image(systemName: "person.fill"), title: Text("Title"))
    }
}
