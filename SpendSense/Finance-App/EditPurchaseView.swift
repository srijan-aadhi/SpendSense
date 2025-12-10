import SwiftUI

struct EditPurchaseView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let purchase: Purchase
    
    @State private var amount: String
    @State private var type: PurchaseType
    @State private var date: Date
    @State private var platform: String
    @State private var note: String
    @State private var showDeleteConfirmation = false
    
    init(purchase: Purchase) {
        self.purchase = purchase
        _amount = State(initialValue: String(format: "%.2f", purchase.amount))
        _type = State(initialValue: purchase.type)
        _date = State(initialValue: purchase.date)
        _platform = State(initialValue: purchase.platform ?? "")
        _note = State(initialValue: purchase.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Purchase Type") {
                    Picker("Type", selection: $type) {
                        ForEach(PurchaseType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }
                Section("Details") {
                    TextField("Amount ($)", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Platform (optional)", text: $platform)
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled((Double(amount) ?? 0) <= 0)
                }
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Delete Purchase", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Delete Purchase?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deletePurchase()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        if let index = store.purchases.firstIndex(where: { $0.id == purchase.id }) {
            var updatedPurchase = purchase
            updatedPurchase.amount = amountValue
            updatedPurchase.type = type
            updatedPurchase.date = date
            updatedPurchase.platform = platform.isEmpty ? nil : platform
            updatedPurchase.note = note.isEmpty ? nil : note
            updatedPurchase.impulsive = type == .unnecessaryImpulse
            
            store.purchases[index] = updatedPurchase
            store.save()
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            dismiss()
        }
    }
    
    private func deletePurchase() {
        if let index = store.purchases.firstIndex(where: { $0.id == purchase.id }) {
            store.purchases.remove(at: index)
            store.save()
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            dismiss()
        }
    }
}

