import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel

    init(dataManager: DataManager) {
        _viewModel = State(initialValue: DashboardViewModel(dataManager: dataManager))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                spendingSummary
                if !viewModel.trialSubscriptions.isEmpty {
                    trialAlerts
                }
                upcomingRenewals
            }
            .padding()
        }
        .frame(maxWidth: 720).frame(maxWidth: .infinity)
        .navigationTitle("SubWake")
        .onAppear { viewModel.loadData() }
    }

    private var spendingSummary: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                SpendingCard(title: "Monthly", amount: viewModel.totalMonthly, color: .blue)
                SpendingCard(title: "Yearly", amount: viewModel.totalYearly, color: .orange)
            }
            HStack {
                Label("\(viewModel.activeCount) active subscriptions", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var trialAlerts: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Free Trials Ending", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            ForEach(viewModel.trialSubscriptions) { sub in
                TrialRow(subscription: sub)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var upcomingRenewals: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Renewals")
                .font(.headline)
            if viewModel.upcomingSubscriptions.isEmpty {
                ContentUnavailableView("No Upcoming Renewals",
                                       systemImage: "checkmark.circle",
                                       description: Text("All clear for the next 30 days"))
            } else {
                ForEach(viewModel.upcomingSubscriptions) { sub in
                    RenewalRow(subscription: sub)
                }
            }
        }
    }
}

struct SpendingCard: View {
    let title: String
    let amount: Decimal
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("$\(NSDecimalNumber(decimal: amount).stringValue)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TrialRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            Text(subscription.iconEmoji)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(subscription.serviceName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let days = subscription.daysUntilTrialEnd {
                    Text(days <= 0 ? "Trial ended" : "\(days) day\(days == 1 ? "" : "s") left")
                        .font(.caption)
                        .foregroundStyle(days <= 1 ? .red : .orange)
                }
            }
            Spacer()
            Text("$\(NSDecimalNumber(decimal: subscription.price).stringValue)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct RenewalRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            Text(subscription.iconEmoji)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(subscription.serviceName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subscription.nextRenewalDate.formattedShort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("$\(NSDecimalNumber(decimal: subscription.price).stringValue)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                let days = subscription.daysUntilRenewal
                Text("\(days) day\(days == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(days <= 3 ? .red : days <= 7 ? .orange : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
