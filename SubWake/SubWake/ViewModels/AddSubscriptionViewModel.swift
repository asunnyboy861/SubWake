import Foundation

@Observable
final class AddSubscriptionViewModel {
    var name: String = ""
    var serviceName: String = ""
    var priceString: String = ""
    var billingCycle: BillingCycle = .monthly
    var category: SubscriptionCategory = .other
    var startDate: Date = Date()
    var isTrial: Bool = false
    var trialEndDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var hasCancellationDeadline: Bool = false
    var cancellationDeadline: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var cancellationNoticeDays: Int = 0
    var colorHex: String = "#007AFF"
    var iconEmoji: String = "📱"
    var reminderDaysBefore: [Int] = [3]
    var notes: String = ""
    var isFamilyShared: Bool = false
    var familyMembersString: String = ""

    var price: Decimal {
        Decimal(string: priceString) ?? 0
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && price > 0
    }

    func reset() {
        name = ""
        serviceName = ""
        priceString = ""
        billingCycle = .monthly
        category = .other
        startDate = Date()
        isTrial = false
        trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        hasCancellationDeadline = false
        cancellationDeadline = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        cancellationNoticeDays = 0
        colorHex = "#007AFF"
        iconEmoji = "📱"
        reminderDaysBefore = [3]
        notes = ""
        isFamilyShared = false
        familyMembersString = ""
    }
}
