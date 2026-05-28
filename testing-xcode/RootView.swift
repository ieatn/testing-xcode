//
//  RootView.swift
//  testing-xcode
//

import SwiftUI

struct RootView: View {
    @Environment(TodoStore.self) private var store

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                OnboardingView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.88), value: store.hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .environment(TodoStore())
}
