//
//  OnboardingView.swift
//  testing-xcode
//

import SwiftUI

struct OnboardingView: View {
    @Environment(TodoStore.self) private var store
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "sparkles",
            title: "Welcome to FlowDesk",
            subtitle: "A calm space to capture tasks and focus on what matters today."
        ),
        OnboardingPage(
            icon: "checkmark.circle.fill",
            title: "Plan with clarity",
            subtitle: "Set priorities, due dates, and notes so nothing important slips through."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Build momentum",
            subtitle: "Check tasks off, track progress, and keep your day moving forward."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if page < pages.count - 1 {
                    Button("Skip") { finish() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    OnboardingPageView(page: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                Button(page == pages.count - 1 ? "Get Started" : "Continue") {
                    if page < pages.count - 1 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                            page += 1
                        }
                    } else {
                        finish()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .appBackground()
    }

    private func finish() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
            store.completeOnboarding()
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.accentSoft)
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accent.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 180, height: 180)

                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 28)
    }
}
