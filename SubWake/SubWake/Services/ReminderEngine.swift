import UserNotifications
import Foundation

@Observable
final class ReminderEngine {
    static let shared = ReminderEngine()

    private let notificationCenter = UNUserNotificationCenter.current()
    var isAuthorized: Bool = false

    private init() {}

    func requestAuthorization() async throws -> Bool {
        let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        isAuthorized = granted
        return granted
    }

    func checkAuthorization() async {
        let settings = await notificationCenter.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleReminders(for subscription: Subscription) async {
        let content = UNMutableNotificationContent()
        content.title = "\(subscription.serviceName) Renewing Soon"
        content.body = String(
            format: "$%@ charge in %d days on %@",
            NSDecimalNumber(decimal: subscription.price).stringValue,
            subscription.daysUntilRenewal,
            subscription.nextRenewalDate.formatted(date: .abbreviated, time: .omitted)
        )
        content.sound = .default
        content.categoryIdentifier = "SUBSCRIPTION_REMINDER"
        content.userInfo = [
            "subscriptionId": subscription.id.uuidString,
            "price": NSDecimalNumber(decimal: subscription.price).stringValue,
            "serviceName": subscription.serviceName
        ]

        let keepAction = UNNotificationAction(identifier: "KEEP_ACTION", title: "Keep It", options: [])
        let remindAction = UNNotificationAction(identifier: "REMIND_LATER", title: "Remind Tomorrow", options: [])
        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details", options: [.foreground])
        let category = UNNotificationCategory(
            identifier: "SUBSCRIPTION_REMINDER",
            actions: [keepAction, remindAction, viewAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        notificationCenter.setNotificationCategories([category, trialCategory, deadlineCategory])

        for daysBefore in subscription.reminderDaysBefore {
            guard let triggerDate = Calendar.current.date(
                byAdding: .day, value: -daysBefore, to: subscription.nextRenewalDate
            ), triggerDate > Date() else { continue }

            let triggerComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(subscription.id.uuidString)_\(daysBefore)",
                content: content, trigger: trigger
            )
            try? await notificationCenter.add(request)
        }
    }

    private var trialCategory: UNNotificationCategory {
        let cancelAction = UNNotificationAction(identifier: "CANCEL_NOW", title: "Set Cancel Reminder", options: [])
        let keepAction = UNNotificationAction(identifier: "KEEP_TRIAL", title: "Keep After Trial", options: [])
        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details", options: [.foreground])
        return UNNotificationCategory(
            identifier: "TRIAL_REMINDER",
            actions: [cancelAction, keepAction, viewAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
    }

    private var deadlineCategory: UNNotificationCategory {
        let viewAction = UNNotificationAction(identifier: "VIEW_ACTION", title: "View Details", options: [.foreground])
        return UNNotificationCategory(
            identifier: "CANCEL_DEADLINE",
            actions: [viewAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
    }

    func scheduleTrialReminder(for subscription: Subscription) async {
        guard subscription.isTrial, let trialEnd = subscription.trialEndDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Free Trial Ending: \(subscription.serviceName)"
        content.body = "Your free trial ends soon. $\(NSDecimalNumber(decimal: subscription.price).stringValue) will be charged on \(trialEnd.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default
        content.categoryIdentifier = "TRIAL_REMINDER"
        content.userInfo = [
            "subscriptionId": subscription.id.uuidString,
            "isTrial": true
        ]

        for daysBefore in [7, 3, 1] {
            guard let triggerDate = Calendar.current.date(
                byAdding: .day, value: -daysBefore, to: trialEnd
            ), triggerDate > Date() else { continue }

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "trial_\(subscription.id.uuidString)_\(daysBefore)",
                content: content, trigger: trigger
            )
            try? await notificationCenter.add(request)
        }
    }

    func scheduleCancellationDeadlineReminder(for subscription: Subscription) async {
        guard let deadline = subscription.cancellationDeadline else { return }

        let content = UNMutableNotificationContent()
        content.title = "Cancel Deadline: \(subscription.serviceName)"
        content.body = "You must cancel by \(deadline.formatted(date: .abbreviated, time: .omitted)) to avoid the next charge."
        content.sound = .default
        content.categoryIdentifier = "CANCEL_DEADLINE"

        for daysBefore in [14, 7, 3, 1] {
            guard let triggerDate = Calendar.current.date(
                byAdding: .day, value: -daysBefore, to: deadline
            ), triggerDate > Date() else { continue }

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: triggerDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "deadline_\(subscription.id.uuidString)_\(daysBefore)",
                content: content, trigger: trigger
            )
            try? await notificationCenter.add(request)
        }
    }

    func cancelAllReminders(for subscriptionId: UUID) {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func refreshAllReminders(subscriptions: [Subscription]) async {
        notificationCenter.removeAllPendingNotificationRequests()
        for sub in subscriptions where sub.isActive {
            await scheduleReminders(for: sub)
            if sub.isTrial { await scheduleTrialReminder(for: sub) }
            if sub.cancellationDeadline != nil { await scheduleCancellationDeadlineReminder(for: sub) }
        }
    }
}
