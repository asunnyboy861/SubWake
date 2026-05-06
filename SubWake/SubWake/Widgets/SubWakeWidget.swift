import WidgetKit
import SwiftUI
import SwiftData

struct SubWakeEntry: TimelineEntry {
    let date: Date
    let upcomingSubscriptions: [SubscriptionWidgetData]
    let monthlyTotal: Decimal
    let yearlyTotal: Decimal
}

struct SubscriptionWidgetData: Identifiable {
    let id: UUID
    let name: String
    let price: Decimal
    let daysUntilRenewal: Int
    let isTrial: Bool
    let colorHex: String
    let iconEmoji: String
}

struct SubWakeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubWakeEntry {
        SubWakeEntry(date: Date(), upcomingSubscriptions: [], monthlyTotal: 0, yearlyTotal: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SubWakeEntry) -> Void) {
        let entry = SubWakeEntry(date: Date(), upcomingSubscriptions: [], monthlyTotal: 0, yearlyTotal: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubWakeEntry>) -> Void) {
        let schema = Schema([Subscription.self, PaymentRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            let entry = SubWakeEntry(date: Date(), upcomingSubscriptions: [], monthlyTotal: 0, yearlyTotal: 0)
            completion(Timeline(entries: [entry], policy: .atEnd))
            return
        }

        let context = container.mainContext
        let descriptor = FetchDescriptor<Subscription>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.nextRenewalDate)]
        )
        let subs = (try? context.fetch(descriptor)) ?? []

        let upcoming = subs.prefix(5).map { sub in
            SubscriptionWidgetData(
                id: sub.id,
                name: sub.serviceName,
                price: sub.price,
                daysUntilRenewal: sub.daysUntilRenewal,
                isTrial: sub.isTrial,
                colorHex: sub.colorHex,
                iconEmoji: sub.iconEmoji
            )
        }

        let monthlyTotal = subs.reduce(Decimal(0)) { $0 + $1.monthlyCost }
        let yearlyTotal = subs.reduce(Decimal(0)) { $0 + $1.yearlyCost }

        let entry = SubWakeEntry(date: Date(), upcomingSubscriptions: upcoming,
                                  monthlyTotal: monthlyTotal, yearlyTotal: yearlyTotal)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct SubWakeWidgetEntryView: View {
    let entry: SubWakeEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(spacing: 8) {
            Text("SubWake")
                .font(.caption)
                .fontWeight(.bold)
            Text("$\(NSDecimalNumber(decimal: entry.monthlyTotal).stringValue)")
                .font(.title2)
                .fontWeight(.bold)
            Text("this month")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let first = entry.upcomingSubscriptions.first {
                Divider()
                Text("\(first.iconEmoji) \(first.name)")
                    .font(.caption2)
                    .lineLimit(1)
                Text("\(first.daysUntilRenewal)d left")
                    .font(.caption2)
                    .foregroundStyle(first.daysUntilRenewal <= 3 ? .red : .secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var mediumView: some View {
        HStack {
            VStack(spacing: 4) {
                Text("SubWake")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("$\(NSDecimalNumber(decimal: entry.monthlyTotal).stringValue)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("/month")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("$\(NSDecimalNumber(decimal: entry.yearlyTotal).stringValue)/year")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text("Upcoming")
                    .font(.caption)
                    .fontWeight(.semibold)
                ForEach(entry.upcomingSubscriptions.prefix(3)) { sub in
                    HStack {
                        Text(sub.iconEmoji)
                        Text(sub.name)
                            .font(.caption2)
                            .lineLimit(1)
                        Spacer()
                        Text("\(sub.daysUntilRenewal)d")
                            .font(.caption2)
                            .foregroundStyle(sub.daysUntilRenewal <= 3 ? .red : .secondary)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var largeView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("SubWake")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("$\(NSDecimalNumber(decimal: entry.monthlyTotal).stringValue)/mo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("$\(NSDecimalNumber(decimal: entry.yearlyTotal).stringValue)/yr")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
            ForEach(entry.upcomingSubscriptions) { sub in
                HStack {
                    Text(sub.iconEmoji)
                        .font(.body)
                    VStack(alignment: .leading) {
                        Text(sub.name)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text("$\(NSDecimalNumber(decimal: sub.price).stringValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if sub.isTrial {
                        Text("TRIAL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Text("\(sub.daysUntilRenewal)d")
                        .font(.caption)
                        .foregroundStyle(sub.daysUntilRenewal <= 3 ? .red : .secondary)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct SubWakeWidget: Widget {
    let kind: String = "SubWakeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SubWakeWidgetProvider()) { entry in
            SubWakeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SubWake")
        .description("Track your upcoming subscription renewals")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
