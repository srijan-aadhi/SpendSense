import SwiftUI

struct LogPurchaseView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var type: PurchaseType = .unnecessaryImpulse
    @State private var date: Date = Date()
    @State private var platform: String = "Instagram"
    @State private var note: String = ""
    @State private var impulsive: Bool = true

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
                    TextField("Amount ($)", text: $amount).keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Platform (optional)", text: $platform)
                    Toggle("Mark as impulsive", isOn: $impulsive)
                    TextField("Explain (optional)", text: $note, axis: .vertical)
                }
                Section {
                    Button("Save") {
                        let val = Double(amount) ?? 0
                        let p = Purchase(date: date, amount: val, type: type, platform: platform.isEmpty ? nil : platform, note: note.isEmpty ? nil : note, impulsive: impulsive)
                        store.purchases.append(p)
                        store.save()
                        dismiss()
                    }
                    .disabled((Double(amount) ?? 0) <= 0)
                }
            }
            .navigationTitle("Log a New Purchase")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}
