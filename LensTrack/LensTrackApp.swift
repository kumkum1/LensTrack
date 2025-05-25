//
//  LensTrackApp.swift
//  LensTrack
//
//  Created by Kumkum Choudhary on 2025-03-14.
//

import SwiftUI
import UserNotifications

@main
struct LensTrackApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if granted {
                print("Notifications granted")
            } else {
                print("Notifications denied")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
