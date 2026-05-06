import SwiftData
import Foundation

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var name: String
    var serviceName: String
    var price: Decimal
    var currency: String
    var billingCycleRaw: String
    var categoryRaw: String
    var startDate: Date
    var nextRenewalDate: Date
    var isTrial: Bool
    var trialEndDate: Date?
    var cancellationDeadline: Date?
    var cancellationNoticeDays: Int
    var isActive: Bool
    var colorHex: String
    var iconEmoji: String
    var previousPrice: Decimal?
    var priceChangeDate: Date?
    var reminderDaysBefore: [Int]
    var notes: String
    var isFamilyShared: Bool
    var familyMembers: [String]
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PaymentRecord.subscription)
    var paymentHistory: [PaymentRecord]

    var billingCycle: BillingCycle {
        get { BillingCycle(rawValue: billingCycleRaw) ?? .monthly }
        set { billingCycleRaw = newValue.rawValue }
    }

    var category: SubscriptionCategory {
        get { SubscriptionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var monthlyCost: Decimal {
        billingCycle.monthlyEquivalent(price: price)
    }

    var yearlyCost: Decimal {
        billingCycle.yearlyEquivalent(price: price)
    }

    var daysUntilRenewal: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextRenewalDate).day ?? 0
    }

    var daysUntilTrialEnd: Int? {
        guard let trialEnd = trialEndDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: trialEnd).day
    }

    var daysUntilCancellationDeadline: Int? {
        guard let deadline = cancellationDeadline else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }

    var hasPriceChange: Bool {
        previousPrice != nil
    }

    init(name: String, serviceName: String = "", price: Decimal = 0.0,
         billingCycle: BillingCycle = .monthly, category: SubscriptionCategory = .other) {
        self.id = UUID()
        self.name = name
        self.serviceName = serviceName.isEmpty ? name : serviceName
        self.price = price
        self.currency = "USD"
        self.billingCycleRaw = billingCycle.rawValue
        self.categoryRaw = category.rawValue
        self.startDate = Date()
        self.nextRenewalDate = Calendar.current.date(byAdding: billingCycle.calendarComponent,
                                                       value: billingCycle.value, to: Date()) ?? Date()
        self.isTrial = false
        self.cancellationNoticeDays = 0
        self.isActive = true
        self.colorHex = "#007AFF"
        self.iconEmoji = "📱"
        self.reminderDaysBefore = [3]
        self.notes = ""
        self.isFamilyShared = false
        self.familyMembers = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.paymentHistory = []
    }
}

@Model
final class PaymentRecord {
    var id: UUID
    var amount: Decimal
    var date: Date
    var subscription: Subscription?

    init(amount: Decimal, date: Date) {
        self.id = UUID()
        self.amount = amount
        self.date = date
    }
}
