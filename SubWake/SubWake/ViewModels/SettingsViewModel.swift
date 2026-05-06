import Foundation

@Observable
final class SettingsViewModel {
    var dataManager: DataManager
    var reminderEngine: ReminderEngine
    var selectedCurrency: String = "USD"
    var notificationEnabled: Bool = false

    init(dataManager: DataManager, reminderEngine: ReminderEngine) {
        self.dataManager = dataManager
        self.reminderEngine = reminderEngine
    }

    func checkNotificationStatus() async {
        await reminderEngine.checkAuthorization()
        notificationEnabled = reminderEngine.isAuthorized
    }

    func requestNotifications() async {
        do {
            let granted = try await reminderEngine.requestAuthorization()
            notificationEnabled = granted
        } catch {
            notificationEnabled = false
        }
    }

    func refreshAllReminders() async {
        let subs = dataManager.fetchActiveSubscriptions()
        await reminderEngine.refreshAllReminders(subscriptions: subs)
    }
}
