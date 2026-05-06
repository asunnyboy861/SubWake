import SwiftData
import Foundation

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiAnnually = "Semi-Annually"
    case annually = "Annually"

    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .quarterly: return .month
        case .semiAnnually: return .month
        case .annually: return .year
        }
    }

    var value: Int {
        switch self {
        case .weekly: return 1
        case .monthly: return 1
        case .quarterly: return 3
        case .semiAnnually: return 6
        case .annually: return 1
        }
    }

    func monthlyEquivalent(price: Decimal) -> Decimal {
        switch self {
        case .weekly: return (price * 433 / 100)
        case .monthly: return price
        case .quarterly: return price / 3
        case .semiAnnually: return price / 6
        case .annually: return price / 12
        }
    }

    func yearlyEquivalent(price: Decimal) -> Decimal {
        switch self {
        case .weekly: return price * 52
        case .monthly: return price * 12
        case .quarterly: return price * 4
        case .semiAnnually: return price * 2
        case .annually: return price
        }
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable {
    case streaming = "Streaming"
    case music = "Music"
    case productivity = "Productivity"
    case fitness = "Fitness"
    case news = "News"
    case cloud = "Cloud Storage"
    case gaming = "Gaming"
    case education = "Education"
    case finance = "Finance"
    case health = "Health"
    case social = "Social"
    case utility = "Utility"
    case charity = "Charity"
    case other = "Other"

    var icon: String {
        switch self {
        case .streaming: return "tv"
        case .music: return "music.note"
        case .productivity: return "laptopcomputer"
        case .fitness: return "figure.run"
        case .news: return "newspaper"
        case .cloud: return "cloud"
        case .gaming: return "gamecontroller"
        case .education: return "book"
        case .finance: return "banknote"
        case .health: return "heart"
        case .social: return "person.2"
        case .utility: return "wrench.and.screwdriver"
        case .charity: return "heart.circle"
        case .other: return "square.grid.2x2"
        }
    }
}
