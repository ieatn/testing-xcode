//
//  ProfileView.swift
//  testing-xcode
//

import SwiftUI

struct ProfileView: View {
    @Environment(TodoStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileHeader

                    VStack(spacing: 12) {
                        settingsRow(
                            icon: "checkmark.seal.fill",
                            title: "Tasks completed",
                            value: "\(store.completedCount)"
                        )
                        settingsRow(
                            icon: "clock.fill",
                            title: "Active tasks",
                            value: "\(store.activeCount)"
                        )
                        settingsRow(
                            icon: "list.bullet.rectangle",
                            title: "Total tasks",
                            value: "\(store.items.count)"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("App")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.leading, 4)

                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                                store.resetOnboarding()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundStyle(AppTheme.accent)
                                Text("Show onboarding again")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                            }
                            .padding(18)
                            .appCard()
                        }
                        .buttonStyle(.plain)
                    }

                    Text("FlowDesk v1.0")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("You")
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentSoft)
                    .frame(width: 72, height: 72)
                Text("DZ")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Dennis")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Building better habits, one task at a time.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .appCard()
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.accent)
        }
        .padding(18)
        .appCard()
    }
}
