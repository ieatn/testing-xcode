//
//  TodoStore.swift
//  testing-xcode
//

import Foundation
import SwiftUI
import UIKit

@Observable
final class TodoStore {
    var items: [TodoItem] = []
    var hasCompletedOnboarding: Bool = false
    var searchText: String = ""

    private let itemsKey = "flowdesk.todos"
    private let onboardingKey = "flowdesk.onboarding"

    init() {
        load()
        if items.isEmpty && hasCompletedOnboarding {
            seedSampleTasks()
        }
    }

    var activeCount: Int {
        items.filter { !$0.isCompleted }.count
    }

    var completedCount: Int {
        items.filter(\.isCompleted).count
    }

    var todayItems: [TodoItem] {
        filteredItems.filter { !$0.isCompleted && ($0.isDueToday || $0.dueDate == nil) }
            .sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }

    var filteredItems: [TodoItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return items }
        return items.filter {
            $0.title.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query)
        }
    }

    func items(filter: TaskFilter) -> [TodoItem] {
        let base = filteredItems
        switch filter {
        case .all:
            return base.sorted { lhs, rhs in
                if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
                return lhs.createdAt > rhs.createdAt
            }
        case .active:
            return base.filter { !$0.isCompleted }
                .sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .done:
            return base.filter(\.isCompleted)
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        if items.isEmpty { seedSampleTasks() }
        save()
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        save()
    }

    func add(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: TodoItem.Priority = .medium
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(
            TodoItem(title: trimmed, notes: notes, dueDate: dueDate, priority: priority),
            at: 0
        )
        save()
    }

    func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let wasCompleted = items[index].isCompleted
        items[index].isCompleted.toggle()
        if !wasCompleted {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        save()
    }

    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func delete(at offsets: IndexSet, in list: [TodoItem]) {
        let ids = offsets.map { list[$0].id }
        items.removeAll { ids.contains($0.id) }
        save()
    }

    func update(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        save()
    }

    func clearCompleted() {
        items.removeAll(where: \.isCompleted)
        save()
    }

    private func seedSampleTasks() {
        items = [
            TodoItem(
                title: "Plan your top 3 priorities",
                notes: "What would make today a win?",
                dueDate: .now,
                priority: .high
            ),
            TodoItem(
                title: "Review project notes",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: .now),
                priority: .medium
            ),
            TodoItem(
                title: "Stretch for 5 minutes",
                priority: .low
            )
        ]
        save()
    }

    private func load() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        guard let data = UserDefaults.standard.data(forKey: itemsKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey)
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: itemsKey)
        }
    }
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all, active, done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .active: "Active"
        case .done: "Done"
        }
    }
}
