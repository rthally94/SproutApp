//
//  PageView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct PageView<Header: View, Controls: View>: View {
    @ViewBuilder var header: (() -> Header)
    @ViewBuilder var controls: (() -> Controls)

    var body: some View {
        VStack {
            VStack {
                Spacer()
                header()
            }

            VStack {
                Spacer()
                controls()
            }

            HStack {
                Spacer()
            }
        }
        .padding()
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView {
            Text("Header")
        } controls: {
            Text("Controls")
        }

    }
}
