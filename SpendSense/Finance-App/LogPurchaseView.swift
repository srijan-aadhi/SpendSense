import SwiftUI

struct PurchaseDraft: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: PurchaseType
    let platform: String?
    let note: String?
    let impulsive: Bool

    func toPurchase() -> Purchase {
        Purchase(
            date: date,
            amount: amount,
            type: type,
            platform: platform,
            note: note,
            impulsive: impulsive
        )
    }
}

struct LogPurchaseView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var type: PurchaseType = .unnecessaryImpulse
    @State private var date: Date = Date()
    @State private var platform: String = ""
    @State private var note: String = ""
    @State private var showHelp = false
    @State private var draftPurchase: PurchaseDraft?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(PurchaseType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                } header: {
                    HStack {
                        Text("Purchase Type")
                        Spacer()
                        Button {
                            showHelp = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                } footer: {
                    Text("Categorize your purchase to better understand your spending habits.")
                }
                
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Where did you buy this? (e.g., Amazon, Store name)", text: $platform)
                    TextField("Add a note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Purchase Details")
                } footer: {
                    Text("Adding details helps you remember and analyze your spending later.")
                }
                Section {
                    Button {
                        guard let val = Double(amount), val > 0 else { return }

                        draftPurchase = PurchaseDraft(
                            date: date,
                            amount: val,
                            type: type,
                            platform: platform.isEmpty ? nil : platform,
                            note: note.isEmpty ? nil : note,
                            impulsive: type == .unnecessaryImpulse
                        )
                    } label: {
                        HStack {
                            Spacer()
                            Label("Save Purchase", systemImage: "checkmark.circle.fill")
                            Spacer()
                        }
                    }
                    .disabled((Double(amount) ?? 0) <= 0)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Log Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpView(
                    title: "Log Purchase",
                    content: """
                    Track your purchases to understand your spending patterns.
                    
                    **Purchase Types:**
                    • Unnecessary Impulse: Things you bought on a whim (e.g., that Instagram ad you clicked)
                    • New Monthly Charge: Recurring expenses like subscriptions or loan payments
                    • Necessary: Essential items like groceries, clothing, or bills
                    • Miscellaneous: Other expenses that don't fit the above categories
                    
                    **Why track purchases?**
                    Understanding where your money goes is the first step to better financial decisions. By categorizing purchases, you can:
                    • Identify spending patterns
                    • See how much you spend on impulse purchases
                    • Make more informed choices about future spending
                    
                    **Real-world tip:**
                    Try logging purchases for a month. You might be surprised by how small purchases add up!
                    """
                )
            }
            .sheet(item: $draftPurchase) { draft in
                PurchaseConfirmationView(
                    draft: draft,
                    onEdit: {
                        draftPurchase = nil
                    },
                    onConfirm: {
                        let purchase = draft.toPurchase()
                        store.purchases.append(purchase)
                        store.save()

                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)

                        dismiss()
                    }
                )
            }
        }
    }
}

struct PurchaseConfirmationView: View {
    let draft: PurchaseDraft
    let onEdit: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                List {
                    Section(header: Text("Purchase Type")) {
                        Text(draft.type.rawValue)
                    }

                    Section(header: Text("Amount")) {
                        Text(draft.amount, format: .currency(code: "USD"))
                    }

                    Section(header: Text("Date")) {
                        Text(draft.date, style: .date)
                    }

                    Section(header: Text("Where")) {
                        Text(draft.platform ?? "—")
                    }

                    if let note = draft.note, !note.isEmpty {
                        Section(header: Text("Note")) {
                            Text(note)
                        }
                    }
                }
                .listStyle(.insetGrouped)

                HStack {
                    Button(role: .cancel) {
                        onEdit()
                    } label: {
                        Text("Edit")
                            .frame(maxWidth: .infinity)
                    }

                    Button {
                        onConfirm()
                    } label: {
                        Text("Confirm & Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("Review Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onEdit()
                    }
                }
            }
        }
    }
}
