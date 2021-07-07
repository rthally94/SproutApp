//
//  Notifications.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct Notifications: View {
    @Binding var currentPage: Int

    fileprivate func buttons() -> some View {
        return VStack {
            Button(action: promptToEnableNotifications, label: {
                Label("Continue", systemImage: "arrowshape.turn.up.right.fill")
                    .labelStyle(TitleOnlyLabelStyle())
            })
            .font(.title3.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .accentColor(.white)
            .background(Capsule().foregroundColor(.green))
        }
    }

    var body: some View {
        PageView {
            Header(image: Image(systemName: "bell.fill"), title: Text("Notifications"), subtitle: Text("Receive updates when your plants need care."))
        } controls: {
            buttons()
        }
    }

    private func promptToEnableNotifications() {
        (UIApplication.shared.delegate as? AppDelegate)?.taskNotificationManager.registerForNotifications { granted in
            showNextPage()
        }
    }

    private func showNextPage() {
        currentPage += 1
    }
}

struct Notifications_Previews: PreviewProvider {
    static var previews: some View {
        Notifications(currentPage: .constant(2))
    }
}
