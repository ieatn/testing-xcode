//
//  TasksListView.swift
//  testing-xcode
//

import SwiftUI

struct TasksListView: View {
    @Environment(TodoStore.self) private var store
    @Binding var showAddTask: Bool
    @State private var filter: TaskFilter = .active
    @State private var selectedItem: TodoItem?

    private var listItems: [TodoItem] {
        store.items(filter: filter)
    }

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                if listItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: filter == .done ? "tray.full.fill" : "tray",
                        title: emptyTitle,
                        subtitle: emptySubtitle
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(listItems) { item in
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
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .appBackground()
            .navigationTitle("Tasks")
            .searchable(text: $store.searchText, prompt: "Search tasks")
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
                if filter == .done && store.completedCount > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Clear") { store.clearCompleted() }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                TaskDetailView(item: item)
            }
        }
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(TaskFilter.allCases) { option in
                Button {
                    withAnimation(.snappy) { filter = option }
                } label: {
                    Text(option.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(filter == option ? .white : AppTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(filter == option ? AppTheme.accent : AppTheme.card)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(filter == option ? 0.08 : 0.04), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var emptyTitle: String {
        switch filter {
        case .all: "No tasks yet"
        case .active: "Nothing active"
        case .done: "No completed tasks"
        }
    }

    private var emptySubtitle: String {
        switch filter {
        case .all: "Tap + to create your first task."
        case .active: "You're caught up — nice work."
        case .done: "Complete tasks to see them here."
        }
    }
}
