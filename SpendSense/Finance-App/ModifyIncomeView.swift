import SwiftUI

struct ModifyIncomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var newAmount: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Add income") {
                    TextField("New income amount", text: $newAmount).keyboardType(.decimalPad)
                    Button("Add") {
                        let val = Double(newAmount) ?? 0
                        guard val > 0 else { return }
                        store.incomes.append(IncomeItem(amount: val, startDate: Date()))
                        newAmount = ""
                        store.save()
                    }
                    .disabled((Double(newAmount) ?? 0) <= 0)
                }
                Section("Existing income") {
                    ForEach(store.incomes) { inc in
                        HStack {
                            Text("$\(inc.amount, specifier: "%.2f")")
                            Spacer()
                            Button("Delete") {
                                if let idx = store.incomes.firstIndex(where: { $0.id == inc.id }) {
                                    store.incomes.remove(at: idx)
                                    store.save()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Modify Monthly Income")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}
