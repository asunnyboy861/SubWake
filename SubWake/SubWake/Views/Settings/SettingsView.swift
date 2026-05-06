import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showContactSupport = false

    init(dataManager: DataManager, reminderEngine: ReminderEngine) {
        _viewModel = State(initialValue: SettingsViewModel(dataManager: dataManager, reminderEngine: reminderEngine))
    }

    var body: some View {
        Form {
            notificationSection
            syncSection
            aboutSection
            supportSection
            legalSection
        }
        .frame(maxWidth: 720).frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .task { await viewModel.checkNotificationStatus() }
    }

    private var notificationSection: some View {
        Section("Notifications") {
            Toggle("Enable Reminders", isOn: Binding(
                get: { viewModel.notificationEnabled },
                set: { newValue in
                    Task {
                        if newValue {
                            await viewModel.requestNotifications()
                        }
                    }
                }
            ))
            Button("Refresh All Reminders") {
                Task { await viewModel.refreshAllReminders() }
            }
        }
    }

    private var syncSection: some View {
        Section("Sync") {
            Toggle("iCloud Sync", isOn: $viewModel.dataManager.useCloudKit)
            Text("Sync your subscriptions across all your devices")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
            LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
            LabeledContent("Privacy", value: "Zero Data Collection")
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Button {
                showContactSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link("Support", destination: URL(string: "https://asunnyboy861.github.io/SubWake/support.html")!)
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/SubWake/privacy.html")!)
        }
    }
}
