//
//  WelcomeView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isVisible: Bool
    @Binding var currentPage: Int
    
    var body: some View {
        PageView {
            Header(image: makeIconImage(), title: Text("Welcome to Sprout"), subtitle: Text("Your plant care companion."))
        } controls: {
            buttons()
        }

    }
    
    fileprivate func showNextPage() {
        withAnimation {
            currentPage += 1
        }
    }
    
    fileprivate func skipOnboarding() {
        isVisible = false
    }
    
    fileprivate func makeIconImage() -> some View {
        Image("Leaf-Dev")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(30)
    }
    
    fileprivate func buttons() -> some View {
        return VStack {
            Button(action: showNextPage, label: {
                Label("Get Started", systemImage: "arrowshape.turn.up.right.fill")
                    .labelStyle(TitleOnlyLabelStyle())
                    .frame(maxWidth: .infinity)
                    .font(.title3.bold())
                    .padding()
            })
            .accentColor(.white)
            .background(Capsule().foregroundColor(.green))
            
            Button(action: skipOnboarding, label: {
                Label("Skip Setup", systemImage: "xmark.circle.fill")
                    .labelStyle(TitleOnlyLabelStyle())
            })
            .font(.title3)
            .frame(minHeight: 44)
        }
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(isVisible: .constant(true), currentPage: .constant(1))
    }
}


