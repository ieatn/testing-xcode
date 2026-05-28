//
//  TodayView.swift
//  testing-xcode
//

import SwiftUI

struct TodayView: View {
    @Environment(TodoStore.self) private var store
    @Binding var showAddTask: Bool
    @State private var selectedItem: TodoItem?

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    headerCard
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }

                if store.todayItems.isEmpty {
                    Section {
                        EmptyStateView(
                            icon: "sun.max.fill",
                            title: "You're all clear",
                            subtitle: "Add a task to shape your day, or enjoy the calm."
                        )
                        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Section {
                        ForEach(store.todayItems) { item in
                            TaskRowView(item: item) {
                                store.toggle(item)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .onTapGesture { selectedItem = item }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Focus list")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .textCase(nil)
                    }
                }

                if store.completedCount > 0 {
                    Section {
                        progressCard
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .appBackground()
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                TaskDetailView(item: item)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(greeting)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Let's make today count")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 12) {
                statPill(value: "\(store.activeCount)", label: "Active")
                statPill(value: "\(store.completedCount)", label: "Done")
                statPill(value: "\(store.todayItems.count)", label: "Today")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.accent.opacity(0.9), AppTheme.accent.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppTheme.accent.opacity(0.35), radius: 16, y: 8)
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .opacity(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var progressCard: some View {
        let total = max(store.activeCount + store.completedCount, 1)
        let progress = Double(store.completedCount) / Double(total)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Daily progress")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            ProgressView(value: progress)
                .tint(AppTheme.success)

            Text("\(Int(progress * 100))% of tracked tasks completed")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(18)
        .appCard()
    }
}
