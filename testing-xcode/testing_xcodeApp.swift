//
//  testing_xcodeApp.swift
//  testing-xcode
//
//  Created by Dennis Zhang on 5/28/26.
//

import SwiftUI

@main
struct testing_xcodeApp: App {
    @State private var store = TodoStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
