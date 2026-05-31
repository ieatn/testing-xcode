//
//  TaskNotificationScheduler.swift
//  testing-xcode
//

import Foundation
import UserNotifications

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationCenterDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

enum TaskNotificationScheduler {
    static let dueHour = 9
    static let dueMinute = 0
    private static let testNotificationID = "flowdesk.test"

    static func sync(items: [TodoItem]) {
        let center = UNUserNotificationCenter.current()

        for item in items {
            let id = item.id.uuidString
            if item.isCompleted || item.dueDate == nil {
                center.removePendingNotificationRequests(withIdentifiers: [id])
            } else {
                scheduleDueDateReminder(for: item)
            }
        }
    }

    static func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "FlowDesk test"
        content.body = "Notifications are working. Due-date reminders arrive at 9:00 AM on the due date."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: testNotificationID,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private static func scheduleDueDateReminder(for item: TodoItem) {
        guard let dueDate = item.dueDate, !item.isCompleted else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        components.hour = dueHour
        components.minute = dueMinute

        guard let fireDate = Calendar.current.date(from: components), fireDate > .now else {
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Task due"
        content.body = "\(item.title) is due today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
