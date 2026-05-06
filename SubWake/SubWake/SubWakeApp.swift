import SwiftUI
import SwiftData

@main
struct SubWakeApp: App {
    let dataManager = DataManager()
    let reminderEngine = ReminderEngine.shared

    var body: some Scene {
        WindowGroup {
            ContentView(dataManager: dataManager, reminderEngine: reminderEngine)
        }
        .modelContainer(dataManager.modelContainer)
    }
}
