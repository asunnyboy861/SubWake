import SwiftUI

struct SubscriptionDetailView: View {
    let subscription: Subscription
    let dataManager: DataManager
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                detailsCard
                if subscription.isTrial { trialCard }
                if subscription.cancellationDeadline != nil { deadlineCard }
                if subscription.hasPriceChange { priceChangeCard }
                if subscription.isFamilyShared { familyCard }
                if !subscription.notes.isEmpty { notesCard }
                paymentHistoryCard
            }
            .padding()
        }
        .frame(maxWidth: 720).frame(maxWidth: .infinity)
        .navigationTitle(subscription.serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        dataManager.toggleActive(subscription)
                    } label: {
                        Label(subscription.isActive ? "Deactivate" : "Activate",
                              systemImage: subscription.isActive ? "pause.circle" : "play.circle")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete Subscription?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                dataManager.deleteSubscription(subscription)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            Text(subscription.iconEmoji)
                .font(.system(size: 56))
            Text(subscription.serviceName)
                .font(.title2)
                .fontWeight(.bold)
            Text("$\(NSDecimalNumber(decimal: subscription.price).stringValue) / \(subscription.billingCycleRaw.lowercased())")
                .font(.title3)
                .foregroundStyle(Color(hex: subscription.colorHex))
            HStack(spacing: 16) {
                VStack {
                    Text("$\(NSDecimalNumber(decimal: subscription.monthlyCost).stringValue)")
                        .font(.headline)
                    Text("Monthly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text("$\(NSDecimalNumber(decimal: subscription.yearlyCost).stringValue)")
                        .font(.headline)
                    Text("Yearly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: subscription.colorHex).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsCard: some View {
        VStack(spacing: 12) {
            DetailRow(label: "Category", value: subscription.categoryRaw)
            DetailRow(label: "Start Date", value: subscription.startDate.formattedShort)
            DetailRow(label: "Next Renewal", value: subscription.nextRenewalDate.formattedShort)
            DetailRow(label: "Days Until Renewal", value: "\(subscription.daysUntilRenewal) days")
            DetailRow(label: "Status", value: subscription.isActive ? "Active" : "Inactive")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var trialCard: some View {
        VStack(spacing: 8) {
            Label("Free Trial", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            if let trialEnd = subscription.trialEndDate {
                DetailRow(label: "Trial Ends", value: trialEnd.formattedShort)
                if let days = subscription.daysUntilTrialEnd {
                    DetailRow(label: "Days Left", value: "\(max(0, days)) days")
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var deadlineCard: some View {
        VStack(spacing: 8) {
            Label("Cancellation Deadline", systemImage: "exclamationmark.shield.fill")
                .foregroundStyle(.red)
            if let deadline = subscription.cancellationDeadline {
                DetailRow(label: "Must Cancel By", value: deadline.formattedShort)
                if let days = subscription.daysUntilCancellationDeadline {
                    DetailRow(label: "Days Until Deadline", value: "\(max(0, days)) days")
                }
            }
            if subscription.cancellationNoticeDays > 0 {
                DetailRow(label: "Notice Period", value: "\(subscription.cancellationNoticeDays) days")
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var priceChangeCard: some View {
        VStack(spacing: 8) {
            Label("Price Change Detected", systemImage: "exclamationmark.arrow.triangle.2.circletriangle")
                .foregroundStyle(.red)
            if let prev = subscription.previousPrice {
                DetailRow(label: "Previous Price", value: "$\(NSDecimalNumber(decimal: prev).stringValue)")
            }
            DetailRow(label: "Current Price", value: "$\(NSDecimalNumber(decimal: subscription.price).stringValue)")
            if let changeDate = subscription.priceChangeDate {
                DetailRow(label: "Changed On", value: changeDate.formattedShort)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var familyCard: some View {
        VStack(spacing: 8) {
            Label("Family Shared", systemImage: "person.2.fill")
                .foregroundStyle(.blue)
            ForEach(subscription.familyMembers, id: \.self) { member in
                HStack {
                    Image(systemName: "person.circle")
                    Text(member)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            Text(subscription.notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var paymentHistoryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment History")
                .font(.headline)
            if subscription.paymentHistory.isEmpty {
                Text("No payments recorded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(subscription.paymentHistory) { record in
                    HStack {
                        Text(record.date.formattedShort)
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: record.amount).stringValue)")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
