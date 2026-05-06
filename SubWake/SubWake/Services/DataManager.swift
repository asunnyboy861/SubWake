import SwiftData
import Foundation

@Observable
final class DataManager {
    var useCloudKit: Bool = false {
        didSet {
            UserDefaults.standard.set(useCloudKit, forKey: "useCloudKit")
        }
    }

    var modelContainer: ModelContainer
    var modelContext: ModelContext {
        modelContainer.mainContext
    }

    init() {
        self.useCloudKit = UserDefaults.standard.bool(forKey: "useCloudKit")
        let schema = Schema([Subscription.self, PaymentRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func createSubscription(name: String, serviceName: String, price: Decimal,
                            billingCycle: BillingCycle, category: SubscriptionCategory,
                            isTrial: Bool = false, trialEndDate: Date? = nil,
                            cancellationDeadline: Date? = nil, cancellationNoticeDays: Int = 0,
                            colorHex: String = "#007AFF", iconEmoji: String = "📱",
                            reminderDaysBefore: [Int] = [3], notes: String = "",
                            isFamilyShared: Bool = false, familyMembers: [String] = []) -> Subscription {
        let sub = Subscription(name: name, serviceName: serviceName, price: price,
                               billingCycle: billingCycle, category: category)
        sub.isTrial = isTrial
        sub.trialEndDate = trialEndDate
        sub.cancellationDeadline = cancellationDeadline
        sub.cancellationNoticeDays = cancellationNoticeDays
        sub.colorHex = colorHex
        sub.iconEmoji = iconEmoji
        sub.reminderDaysBefore = reminderDaysBefore
        sub.notes = notes
        sub.isFamilyShared = isFamilyShared
        sub.familyMembers = familyMembers
        modelContext.insert(sub)
        try? modelContext.save()
        return sub
    }

    func updateSubscription(_ sub: Subscription) {
        sub.updatedAt = Date()
        try? modelContext.save()
    }

    func deleteSubscription(_ sub: Subscription) {
        modelContext.delete(sub)
        try? modelContext.save()
    }

    func toggleActive(_ sub: Subscription) {
        sub.isActive.toggle()
        sub.updatedAt = Date()
        try? modelContext.save()
    }

    func fetchAllSubscriptions() -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(sortBy: [SortDescriptor(\.nextRenewalDate)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchActiveSubscriptions() -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.nextRenewalDate)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUpcomingSubscriptions(days: Int = 30) -> [Subscription] {
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.isActive && $0.nextRenewalDate <= futureDate },
            sortBy: [SortDescriptor(\.nextRenewalDate)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchTrialSubscriptions() -> [Subscription] {
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.isTrial && $0.isActive }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var totalMonthly: Decimal {
        fetchActiveSubscriptions().reduce(0) { $0 + $1.monthlyCost }
    }

    var totalYearly: Decimal {
        fetchActiveSubscriptions().reduce(0) { $0 + $1.yearlyCost }
    }
}
