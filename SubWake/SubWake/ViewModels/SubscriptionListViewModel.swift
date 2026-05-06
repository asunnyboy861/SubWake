import Foundation
import SwiftData

@Observable
final class SubscriptionListViewModel {
    var dataManager: DataManager
    var searchText: String = ""
    var selectedCategory: SubscriptionCategory?
    var showInactive: Bool = false

    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    var filteredSubscriptions: [Subscription] {
        var subs = showInactive ? dataManager.fetchAllSubscriptions() : dataManager.fetchActiveSubscriptions()
        if !searchText.isEmpty {
            subs = subs.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.serviceName.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let category = selectedCategory {
            subs = subs.filter { $0.categoryRaw == category.rawValue }
        }
        return subs
    }
}
