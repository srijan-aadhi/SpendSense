import SwiftUI

struct ModifyIncomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var newAmount: String = ""
    @State private var incomeMonth: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Add income") {
                    TextField("New income amount", text: $newAmount).keyboardType(.decimalPad)
                    DatePicker("Month", selection: $incomeMonth, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                    Button("Add") {
                        let val = Double(newAmount) ?? 0
                        guard val > 0 else { return }
                        let startOfMonth = Calendar.current.date(
                            from: Calendar.current.dateComponents([.year, .month], from: incomeMonth)
                        ) ?? incomeMonth
                        store.incomes.append(IncomeItem(amount: val, startDate: startOfMonth))
                        newAmount = ""
                        incomeMonth = Date()
                        store.save()
                    }
                    .disabled((Double(newAmount) ?? 0) <= 0)
                }
                Section("Existing income") {
                    ForEach(store.incomes) { inc in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("$\(inc.amount, specifier: "%.2f")")
                                Text(monthFormatter.string(from: inc.startDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
    
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }
}
