import SwiftUI

struct ContentView: View {
    let dataManager: DataManager
    let reminderEngine: ReminderEngine
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(dataManager: dataManager)
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.pie")
            }
            .tag(0)

            NavigationStack {
                SubscriptionListView(dataManager: dataManager)
            }
            .tabItem {
                Label("Subscriptions", systemImage: "list.bullet.rectangle")
            }
            .tag(1)

            NavigationStack {
                AddSubscriptionView(dataManager: dataManager, reminderEngine: reminderEngine)
            }
            .tabItem {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .tag(2)

            NavigationStack {
                SettingsView(dataManager: dataManager, reminderEngine: reminderEngine)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(3)
        }
    }
}
