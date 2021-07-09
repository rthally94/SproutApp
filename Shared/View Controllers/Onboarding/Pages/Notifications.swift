//
//  Notifications.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct Notifications: View {
    @Binding var isVisible: Bool
    @Binding var currentPage: Int
    
    fileprivate func buttons() -> some View {
        return VStack {
            Button(action: promptToEnableNotifications, label: {
                Label("Continue", systemImage: "arrowshape.turn.up.right.fill")
                    .labelStyle(TitleOnlyLabelStyle())
                    .font(.title3.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .accentColor(.white)
            .background(Capsule().foregroundColor(.green))
        }
    }
    
    var body: some View {
        PageView {
            Header(image: makeIconImage(), title: Text("Notifications"), subtitle: Text("Receive updates when\nyour plants need care."))
        } controls: {
            VStack {
                Spacer()
                buttons()
                Text("You can change this anytime\nin the Settings app.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(minHeight: 44)
                    
            }
        }
    }
    
    private func makeIconImage() -> some View {
        Image(systemName: "bell.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
    }
    
    private func promptToEnableNotifications() {
        (UIApplication.shared.delegate as? AppDelegate)?.taskNotificationManager.registerForNotifications { granted in
            showNextPage()
        }
    }
    
    private func showNextPage() {
        withAnimation {
            currentPage += 1
        }
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications(isVisible: .constant(true), currentPage: .constant(2))
    }
}
