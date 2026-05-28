//
//  TaskRowView.swift
//  testing-xcode
//

import SwiftUI

struct TaskRowView: View {
    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? AppTheme.success : AppTheme.textSecondary.opacity(0.35), lineWidth: 2)
                        .frame(width: 26, height: 26)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.success)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(item.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary)
                    .strikethrough(item.isCompleted, color: AppTheme.textSecondary)

                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    PriorityBadge(priority: item.priority)

                    if let dueDate = item.dueDate {
                        Label(dueLabel(for: dueDate), systemImage: "calendar")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(item.isOverdue ? .red.opacity(0.85) : AppTheme.textSecondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .appCard()
        .opacity(item.isCompleted ? 0.72 : 1)
        .animation(.snappy, value: item.isCompleted)
    }

    private func dueLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

struct PriorityBadge: View {
    let priority: TodoItem.Priority

    var body: some View {
        Text(priority.label)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch priority {
        case .low: AppTheme.textSecondary
        case .medium: AppTheme.accent
        case .high: Color.red.opacity(0.85)
        }
    }

    private var background: Color {
        switch priority {
        case .low: AppTheme.textSecondary.opacity(0.12)
        case .medium: AppTheme.accentSoft
        case .high: Color.red.opacity(0.1)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(AppTheme.accent.opacity(0.7))
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text(subtitle)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}
