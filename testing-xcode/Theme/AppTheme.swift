//
//  AppTheme.swift
//  testing-xcode
//

import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.22, green: 0.48, blue: 0.96)
    static let accentSoft = Color(red: 0.22, green: 0.48, blue: 0.96).opacity(0.14)
    static let success = Color(red: 0.18, green: 0.72, blue: 0.52)
    static let surface = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let card = Color.white
    static let textPrimary = Color(red: 0.09, green: 0.11, blue: 0.16)
    static let textSecondary = Color(red: 0.45, green: 0.48, blue: 0.55)

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.96, blue: 1.0),
            Color(red: 0.98, green: 0.97, blue: 0.99),
            AppTheme.surface
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

}

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
    }
}

struct AppCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }

    func appCard() -> some View {
        modifier(AppCard())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
