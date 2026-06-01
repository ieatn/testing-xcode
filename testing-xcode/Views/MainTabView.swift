//
//  MainTabView.swift
//  testing-xcode
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddTask = false

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(showAddTask: $showAddTask)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            TasksListView(showAddTask: $showAddTask)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(1)

            FlappyBirdView()
                .tabItem {
                    Label("Flappy", systemImage: "gamecontroller.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("You", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.accent)
        .sheet(isPresented: $showAddTask) {
            AddTaskSheet()
        }
    }
}
