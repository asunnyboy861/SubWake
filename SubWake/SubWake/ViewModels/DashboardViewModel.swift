import Foundation
import SwiftData

@Observable
final class DashboardViewModel {
    var dataManager: DataManager
    var upcomingSubscriptions: [Subscription] = []
    var trialSubscriptions: [Subscription] = []
    var totalMonthly: Decimal = 0
    var totalYearly: Decimal = 0
    var activeCount: Int = 0

    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    func loadData() {
        upcomingSubscriptions = dataManager.fetchUpcomingSubscriptions(days: 30)
        trialSubscriptions = dataManager.fetchTrialSubscriptions()
        totalMonthly = dataManager.totalMonthly
        totalYearly = dataManager.totalYearly
        activeCount = dataManager.fetchActiveSubscriptions().count
    }
}
