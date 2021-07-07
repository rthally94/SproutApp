//
//  WelcomeView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentPage: Int

    fileprivate func headerView() -> some View {
        return VStack(alignment: .center) {
            Image(systemName: "leaf.fill")
                .resizable()
                .frame(width: 100, height: 100)

            Text("Welcome to Sprout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Text("Your plant care companion")
        }
    }

    fileprivate func buttons() -> some View {
        return VStack {
            Button(action: showNextPage, label: {
                Label("Get Started", systemImage: "arrowshape.turn.up.right.fill")
                    .labelStyle(TitleOnlyLabelStyle())
            })
            .font(.title3.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .accentColor(.white)
            .background(Capsule().foregroundColor(.green))

            Button(action: skipOnboarding, label: {
                Label("Skip Setup", systemImage: "xmark.circle.fill")
                    .labelStyle(TitleOnlyLabelStyle())
            })
            .accentColor(.secondary)
            .padding()
        }
    }

    var body: some View {
        VStack {
            Spacer()
            headerView()
            Spacer()

            buttons()

            HStack {
                Spacer()
            }
        }
        .padding()
    }

    fileprivate func showNextPage() {
        currentPage += 1
    }

    fileprivate func skipOnboarding() {
        currentPage = 0
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(currentPage: .constant(1))
    }
}
