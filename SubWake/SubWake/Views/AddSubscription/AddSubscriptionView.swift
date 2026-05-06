import SwiftUI

struct AddSubscriptionView: View {
    @State private var viewModel: AddSubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    private let dataManager: DataManager
    private let reminderEngine: ReminderEngine

    init(dataManager: DataManager, reminderEngine: ReminderEngine) {
        self.dataManager = dataManager
        self.reminderEngine = reminderEngine
        _viewModel = State(initialValue: AddSubscriptionViewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                billingSection
                trialSection
                cancellationSection
                reminderSection
                appearanceSection
                familySection
                notesSection
            }
            .frame(maxWidth: 720).frame(maxWidth: .infinity)
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Name", text: $viewModel.name)
            TextField("Service Name", text: $viewModel.serviceName)
            Picker("Category", selection: $viewModel.category) {
                ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }
        }
    }

    private var billingSection: some View {
        Section("Billing") {
            HStack {
                Text("$")
                TextField("Price", text: $viewModel.priceString)
                    .keyboardType(.decimalPad)
            }
            Picker("Billing Cycle", selection: $viewModel.billingCycle) {
                ForEach(BillingCycle.allCases, id: \.self) { cycle in
                    Text(cycle.rawValue).tag(cycle)
                }
            }
            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
        }
    }

    private var trialSection: some View {
        Section("Free Trial") {
            Toggle("Is Free Trial", isOn: $viewModel.isTrial)
            if viewModel.isTrial {
                DatePicker("Trial End Date", selection: $viewModel.trialEndDate, displayedComponents: .date)
            }
        }
    }

    private var cancellationSection: some View {
        Section("Cancellation Deadline") {
            Toggle("Has Cancellation Deadline", isOn: $viewModel.hasCancellationDeadline)
            if viewModel.hasCancellationDeadline {
                DatePicker("Deadline", selection: $viewModel.cancellationDeadline, displayedComponents: .date)
                Stepper("Notice Period: \(viewModel.cancellationNoticeDays) days",
                        value: $viewModel.cancellationNoticeDays, in: 0...90)
            }
        }
    }

    private var reminderSection: some View {
        Section("Reminders") {
            ForEach([1, 3, 7, 14, 30], id: \.self) { days in
                Toggle("\(days) day\(days == 1 ? "" : "s") before", isOn: Binding(
                    get: { viewModel.reminderDaysBefore.contains(days) },
                    set: { on in
                        if on {
                            viewModel.reminderDaysBefore.append(days)
                            viewModel.reminderDaysBefore.sort()
                        } else {
                            viewModel.reminderDaysBefore.removeAll { $0 == days }
                        }
                    }
                ))
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            TextField("Icon Emoji", text: $viewModel.iconEmoji)
            ColorPickerRow(selectedHex: $viewModel.colorHex)
        }
    }

    private var familySection: some View {
        Section("Family") {
            Toggle("Family Shared", isOn: $viewModel.isFamilyShared)
            if viewModel.isFamilyShared {
                TextField("Family Members (comma separated)", text: $viewModel.familyMembersString)
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Notes", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private func saveSubscription() {
        let familyMembers = viewModel.isFamilyShared ?
            viewModel.familyMembersString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } : []

        let sub = dataManager.createSubscription(
            name: viewModel.name.trimmingCharacters(in: .whitespaces),
            serviceName: viewModel.serviceName.trimmingCharacters(in: .whitespaces),
            price: viewModel.price,
            billingCycle: viewModel.billingCycle,
            category: viewModel.category,
            isTrial: viewModel.isTrial,
            trialEndDate: viewModel.isTrial ? viewModel.trialEndDate : nil,
            cancellationDeadline: viewModel.hasCancellationDeadline ? viewModel.cancellationDeadline : nil,
            cancellationNoticeDays: viewModel.cancellationNoticeDays,
            colorHex: viewModel.colorHex,
            iconEmoji: viewModel.iconEmoji,
            reminderDaysBefore: viewModel.reminderDaysBefore,
            notes: viewModel.notes,
            isFamilyShared: viewModel.isFamilyShared,
            familyMembers: familyMembers
        )

        Task {
            await reminderEngine.scheduleReminders(for: sub)
            if sub.isTrial {
                await reminderEngine.scheduleTrialReminder(for: sub)
            }
            if sub.cancellationDeadline != nil {
                await reminderEngine.scheduleCancellationDeadlineReminder(for: sub)
            }
        }

        dismiss()
    }
}

struct ColorPickerRow: View {
    @Binding var selectedHex: String
    private let colors = ["#007AFF", "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
                          "#5AC8FA", "#AF52DE", "#FF2D55", "#5856D6", "#8E8E93"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(colors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay {
                            if selectedHex == hex {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .onTapGesture { selectedHex = hex }
                }
            }
        }
    }
}
