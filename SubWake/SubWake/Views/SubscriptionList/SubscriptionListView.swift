import SwiftUI

struct SubscriptionListView: View {
    @State private var viewModel: SubscriptionListViewModel
    @State private var selectedSubscription: Subscription?
    @State private var showInactive = false

    init(dataManager: DataManager) {
        _viewModel = State(initialValue: SubscriptionListViewModel(dataManager: dataManager))
    }

    var body: some View {
        List {
            Section {
                Toggle("Show Inactive", isOn: $showInactive)
                    .onChange(of: showInactive) { _, newValue in
                        viewModel.showInactive = newValue
                    }
            }
            Section {
                ForEach(viewModel.filteredSubscriptions) { sub in
                    NavigationLink(destination: SubscriptionDetailView(subscription: sub, dataManager: viewModel.dataManager)) {
                        SubscriptionRow(subscription: sub)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.dataManager.deleteSubscription(sub)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.dataManager.toggleActive(sub)
                        } label: {
                            Label(sub.isActive ? "Deactivate" : "Activate",
                                  systemImage: sub.isActive ? "pause.circle" : "play.circle")
                        }
                        .tint(sub.isActive ? .orange : .green)
                    }
                }
            }
        }
        .frame(maxWidth: 720).frame(maxWidth: .infinity)
        .searchable(text: $viewModel.searchText, prompt: "Search subscriptions")
        .navigationTitle("Subscriptions")
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            Text(subscription.iconEmoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(subscription.serviceName)
                        .font(.body)
                        .fontWeight(.medium)
                    if subscription.isTrial {
                        Text("TRIAL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    if subscription.hasPriceChange {
                        Image(systemName: "exclamationmark.arrow.triangle.2.circletriangle")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                Text("\(subscription.billingCycleRaw) - \(subscription.categoryRaw)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("$\(NSDecimalNumber(decimal: subscription.price).stringValue)")
                    .font(.body)
                    .fontWeight(.semibold)
                if !subscription.isActive {
                    Text("Inactive")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
        .opacity(subscription.isActive ? 1.0 : 0.5)
    }
}
