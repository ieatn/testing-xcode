//
//  testing_xcodeApp.swift
//  testing-xcode
//
//  Created by Dennis Zhang on 5/28/26.
//

import SwiftUI
import UserNotifications

@main
struct testing_xcodeApp: App {
    @State private var store = TodoStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .task {
                    _ = try? await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.badge])
                    store.refreshAppBadge()
                }
        }
    }
}
