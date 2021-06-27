//
//  SettingsView.swift
//  Sprout
//
//  Created by Ryan Thally on 6/7/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.dailyDigestIsEnabled.rawValue) var isDailyDigestEnabled = false
    @AppStorage(UserDefaults.Keys.dailyDigestDate.rawValue) var dailyDigestDate = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date())!

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $isDailyDigestEnabled, label: {
                        Label("Daily Digest", systemImage: "bell.badge")
                    })

                    if isDailyDigestEnabled {
                        DatePicker("Time", selection: $dailyDigestDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }

                Section {
                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Label("Feedback", systemImage: "arrow.up.message")
                        }
                    )

                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Label("Support", systemImage: "exclamationmark.bubble")
                        }
                    )
                }

                Section {
                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Label("About", systemImage: "questionmark.square")
                        }
                    )

                    NavigationLink(
                        destination: Text("Destination"),
                        label: {
                            Label("Privacy", systemImage: "lock.shield")
                        }
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
