//
//  OnboardingContainerView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Binding var isVisible: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView(isVisible: $isVisible, currentPage: $currentPage)
                .transition(.slide)
                .tag(0)
            Notifications(isVisible: $isVisible, currentPage: $currentPage)
                .transition(.slide)
                .tag(1)
            SampleData(isVisible: $isVisible, currentPage: $currentPage)
                .transition(.slide)
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never ))
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView(isVisible: .constant(true))
    }
}
