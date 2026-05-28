//
//  AddTaskSheet.swift
//  testing-xcode
//

import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoStore.self) private var store

    @State private var title = ""
    @State private var notes = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var priority: TodoItem.Priority = .medium

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField("What do you need to do?", text: $title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .padding(16)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField("Optional details", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(16)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    VStack(spacing: 0) {
                        Toggle("Due date", isOn: $hasDueDate.animation(.snappy))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .tint(AppTheme.accent)
                            .padding(16)

                        if hasDueDate {
                            Divider().padding(.leading, 16)
                            DatePicker(
                                "Due",
                                selection: $dueDate,
                                displayedComponents: [.date]
                            )
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(16)
                        }
                    }
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Priority")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)

                        HStack(spacing: 10) {
                            ForEach(TodoItem.Priority.allCases) { level in
                                Button {
                                    priority = level
                                } label: {
                                    Text(level.label)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(priority == level ? .white : AppTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(priority == level ? AppTheme.accent : AppTheme.card)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .appBackground()
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addTask() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func addTask() {
        store.add(
            title: title,
            notes: notes,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority
        )
        dismiss()
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TodoStore.self) private var store
    @State var item: TodoItem

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Title", text: $item.title)
                    TextField("Notes", text: $item.notes, axis: .vertical)
                }

                Section("Schedule") {
                    Toggle("Due date", isOn: Binding(
                        get: { item.dueDate != nil },
                        set: { item.dueDate = $0 ? (item.dueDate ?? .now) : nil }
                    ))
                    if item.dueDate != nil {
                        DatePicker("Due", selection: Binding(
                            get: { item.dueDate ?? .now },
                            set: { item.dueDate = $0 }
                        ), displayedComponents: .date)
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $item.priority) {
                        ForEach(TodoItem.Priority.allCases) { level in
                            Text(level.label).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Completed", isOn: $item.isCompleted)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.update(item)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
