import SwiftUI

struct ModifyIncomeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var newAmount: String = ""
    @State private var incomeMonth: Date = Date()
    @State private var incomeToEdit: IncomeItem?
    @State private var showUndoAlert = false
    @State private var lastDeletedIncome: IncomeItem?
    @State private var lastDeletedIndex: Int?
    @State private var statusMessage: String?
    @State private var statusType: StatusMessageView.StatusType?
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Income amount ($)", text: $newAmount)
                        .keyboardType(.decimalPad)
                    DatePicker("Month", selection: $incomeMonth, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                    Button {
                        addIncome()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Add Income", systemImage: "plus.circle.fill")
                            Spacer()
                        }
                    }
                    .disabled((Double(newAmount) ?? 0) <= 0)
                    .buttonStyle(.borderedProminent)
                } header: {
                    Text("Add New Income")
                } footer: {
                    Text("Add your monthly income to track your spending patterns and debt-to-income ratio.")
                }
                
                Section {
                    if store.incomes.isEmpty {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundStyle(.secondary)
                            Text("No income entries yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(store.incomes.sorted(by: { $0.startDate > $1.startDate })) { inc in
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("$\(inc.amount, specifier: "%.2f")")
                                        .font(.headline)
                                    Text(monthFormatter.string(from: inc.startDate))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Menu {
                                    Button(role: .destructive, action: {
                                        deleteIncome(inc)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Existing Income")
                } footer: {
                    if !store.incomes.isEmpty {
                        Text("Swipe or use the menu to delete income entries.")
                    }
                }
            }
            .navigationTitle("Monthly Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Income Deleted", isPresented: $showUndoAlert) {
                Button("Undo", role: .cancel) {
                    if let income = lastDeletedIncome, let index = lastDeletedIndex {
                        store.incomes.insert(income, at: min(index, store.incomes.count))
                        store.save()
                        lastDeletedIncome = nil
                        lastDeletedIndex = nil
                    }
                }
                Button("OK", role: .destructive) {
                    lastDeletedIncome = nil
                    lastDeletedIndex = nil
                }
            } message: {
                Text("Income entry deleted. You can undo this action.")
            }
            .statusMessage(message: $statusMessage, type: $statusType)
            .overlay {
                if isProcessing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    private func addIncome() {
        let val = Double(newAmount) ?? 0
        guard val > 0 else { return }
        
        isProcessing = true
        statusMessage = "Adding income..."
        statusType = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let startOfMonth = Calendar.current.date(
                from: Calendar.current.dateComponents([.year, .month], from: incomeMonth)
            ) ?? incomeMonth
            store.incomes.append(IncomeItem(amount: val, startDate: startOfMonth))
            newAmount = ""
            incomeMonth = Date()
            store.save()
            
            isProcessing = false
            statusMessage = "Income added successfully!"
            statusType = .success
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    private func deleteIncome(_ income: IncomeItem) {
        isProcessing = true
        statusMessage = "Deleting income..."
        statusType = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let index = store.incomes.firstIndex(where: { $0.id == income.id }) {
                lastDeletedIncome = income
                lastDeletedIndex = index
                store.incomes.remove(at: index)
                store.save()
                
                isProcessing = false
                statusMessage = "Income deleted"
                statusType = .success
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                showUndoAlert = true
            }
        }
    }
    
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df
    }
}
