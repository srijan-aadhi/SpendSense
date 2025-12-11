import SwiftUI
import Charts

struct SpendingTrackerView: View {
    @EnvironmentObject var store: AppStore
    @State private var showLogPurchase = false
    @State private var showModifyIncome = false
    @State private var purchaseToEdit: Purchase?
    @State private var showUndoAlert = false
    @State private var lastDeletedPurchase: Purchase?
    @State private var lastDeletedIndex: Int?
    @State private var showHelp = false
    @State private var statusMessage: String?
    @State private var statusType: StatusMessageView.StatusType?
    
    private let spendingSuggestions: [String] = [
        "Cap impulse spending to a weekly limit you decide, then log it here.",
        "Tag recurring charges and review monthly—cancel anything unused.",
        "Try shifting one impulse purchase per week into savings instead."
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 20) {
                    // Chart section
                    VStack(spacing: 12) {
                        SpendingChart(purchases: store.purchases, incomes: store.incomes)
                            .frame(height: 240)
                        
                        // Summary card with better visual hierarchy
                        VStack(spacing: 8) {
                            Text("Current Debt:Income Ratio")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(debtToIncomeRatio, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(debtToIncomeRatio > 0.3 ? .red : .green)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    // Suggestions (upper-middle placement)
                    SuggestionCard(
                        title: "Spending Suggestions",
                        suggestions: spendingSuggestions,
                        icon: "lightbulb.fill",
                        tint: .orange
                    )
                    .padding(.horizontal)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showLogPurchase = true
                        } label: {
                            Label("Log Purchase", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            showModifyIncome = true
                        } label: {
                            Label("Income", systemImage: "dollarsign.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)

                    // Recent purchases list
                    if !store.purchases.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Purchases")
                                    .font(.headline)
                                Spacer()
                                Text("\(store.purchases.count) total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)

                            ForEach(purchasesByMonth) { section in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(section.label)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("\(section.purchases.count) purchases")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal)

                                    ForEach(section.purchases) { purchase in
                                        PurchaseRowView(purchase: purchase) {
                                            purchaseToEdit = purchase
                                        } onDelete: {
                                            deletePurchase(purchase)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No purchases yet")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Tap 'Log Purchase' to get started")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Spending Tracker")
            .toolbar {
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
                    title: "Spending Tracker",
                    content: """
                    Track your spending to understand your financial habits.
                    
                    **How to use:**
                    • Log purchases to track where your money goes
                    • View your spending patterns in the chart
                    • Monitor your debt-to-income ratio
                    
                    **Debt-to-Income Ratio:**
                    This shows the ratio of unnecessary impulse spending to your monthly income. A lower ratio (under 0.3) is generally healthier.
                    
                    **Purchase Types:**
                    • Unnecessary Impulse: Non-essential purchases you didn't plan
                    • New Monthly Charge: Recurring expenses (subscriptions, loans)
                    • Necessary: Essential items like food and clothing
                    • Miscellaneous: Other expenses
                    
                    **Tips:**
                    • Review your purchases regularly to identify spending patterns
                    • Edit or delete purchases if you make a mistake
                    • Keep your debt-to-income ratio low for better financial health
                    """
                )
            }
            .sheet(isPresented: $showLogPurchase) { 
                LogPurchaseView()
            }
            .sheet(isPresented: $showModifyIncome) { 
                ModifyIncomeView()
            }
            .sheet(item: $purchaseToEdit) { purchase in
                EditPurchaseView(purchase: purchase)
            }
            .alert("Purchase Deleted", isPresented: $showUndoAlert) {
                Button("Undo", role: .cancel) {
                    if let purchase = lastDeletedPurchase, let index = lastDeletedIndex {
                        store.purchases.insert(purchase, at: min(index, store.purchases.count))
                        store.save()
                        lastDeletedPurchase = nil
                        lastDeletedIndex = nil
                    }
                }
                Button("OK", role: .destructive) {
                    lastDeletedPurchase = nil
                    lastDeletedIndex = nil
                }
            } message: {
                Text("Purchase deleted. You can undo this action.")
            }
            .statusMessage(message: $statusMessage, type: $statusType)
        }
    }
    
    private func deletePurchase(_ purchase: Purchase) {
        statusMessage = "Deleting purchase..."
        statusType = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let index = store.purchases.firstIndex(where: { $0.id == purchase.id }) {
                lastDeletedPurchase = purchase
                lastDeletedIndex = index
                store.purchases.remove(at: index)
                store.save()
                
                statusMessage = "Purchase deleted"
                statusType = .success
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                showUndoAlert = true
            }
        }
    }

    private struct PurchaseMonthSection: Identifiable {
        let id = UUID()
        let label: String
        let purchases: [Purchase]
    }

    private var purchasesByMonth: [PurchaseMonthSection] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        // Sort purchases newest first
        let sorted = store.purchases.sorted { $0.date > $1.date }

        // Group by month start date
        let grouped = Dictionary(grouping: sorted) { purchase -> Date in
            calendar.date(from: calendar.dateComponents([.year, .month], from: purchase.date)) ?? purchase.date
        }

        // Map to sections and sort sections by most recent month first
        let sections: [PurchaseMonthSection] = grouped.map { (monthStart, purchases) in
            let label = formatter.string(from: monthStart)
            let monthPurchases = purchases.sorted { $0.date > $1.date }
            return PurchaseMonthSection(label: label, purchases: monthPurchases)
        }

        return sections.sorted { first, second in
            // Use the first purchase date in each section to sort, newest month first
            let firstDate = first.purchases.first?.date ?? .distantPast
            let secondDate = second.purchases.first?.date ?? .distantPast
            return firstDate > secondDate
        }
    }

    var debtToIncomeRatio: Double {
        let unnecessary = store.purchases
            .filter { $0.type == .unnecessaryImpulse }
            .map { $0.amount }
            .reduce(0,+)
        let income = store.incomes.map{ $0.amount }.reduce(0,+)
        guard income > 0 else { return 0 }
        return unnecessary / income
    }
}

struct SpendingChart: View {
    let purchases: [Purchase]
    let incomes: [IncomeItem]
    let monthsBack: Int = 6
    @State private var animateChart = false

    var body: some View {
        let data = monthlyData
        
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Month", point.label),
                    y: .value("Amount", point.totalSpend)
                )
                .symbol(.circle)
                .foregroundStyle(by: .value("Series", "Total Spending"))
                .interpolationMethod(.catmullRom)
            }
            
            ForEach(data) { point in
                LineMark(
                    x: .value("Month", point.label),
                    y: .value("Amount", point.impulsiveSpend)
                )
                .symbol(.circle)
                .foregroundStyle(by: .value("Series", "Unnecessary Impulse"))
                .interpolationMethod(.catmullRom)
            }
            
            ForEach(data) { point in
                LineMark(
                    x: .value("Month", point.label),
                    y: .value("Amount", point.income)
                )
                .symbol(.circle)
                .foregroundStyle(by: .value("Series", "Income"))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartYAxisLabel("$ per month")
        .chartYScale(domain: 0...(maxY * 1.1))
        .chartForegroundStyleScale([
            "Total Spending": Color.accentColor,
            "Unnecessary Impulse": Color.red,
            "Income": Color.green
        ])
        .chartLegend(position: .bottom)
        .opacity(animateChart ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0), value: animateChart)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateChart = true
            }
        }
        .onChange(of: purchases.count) { oldValue, newValue in
            animateChart = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateChart = true
                }
            }
        }
        .onChange(of: incomes.count) { oldValue, newValue in
            animateChart = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateChart = true
                }
            }
        }
    }
    
    private struct MonthlySummary: Identifiable {
        let id = UUID()
        let monthStart: Date
        let label: String
        let totalSpend: Double
        let impulsiveSpend: Double
        let income: Double
    }
    
    private var monthlyData: [MonthlySummary] {
        let calendar = Calendar.current
        let now = Date()
        
        let currentMonthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) ?? now
        
        var monthStarts: [Date] = []
        for offset in stride(from: monthsBack - 1, through: 0, by: -1) {
            if let date = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart)
            {
                monthStarts.append(date)
            }
        }
        
        let formatter = monthFormatter
        var results: [MonthlySummary] = []
        
        for monthStart in monthStarts {
            guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                continue
            }
            
            let monthPurchases = purchases
                .filter { $0.date >= monthStart && $0.date < monthEnd }
            let impulsiveSpend = monthPurchases
                .filter { $0.type == .unnecessaryImpulse }
                .map { $0.amount }
                .reduce(0, +)
            let totalSpend = monthPurchases
                .map { $0.amount }
                .reduce(0, +)
            
            let label = formatter.string(from: monthStart)
            
            let incomeForMonth = incomes
                .filter { income in
                    income.startDate >= monthStart && income.startDate < monthEnd
                }
                .map { $0.amount }
                .reduce(0, +)
            
            results.append(
                MonthlySummary(
                    monthStart: monthStart,
                    label: label,
                    totalSpend: totalSpend,
                    impulsiveSpend: impulsiveSpend,
                    income: incomeForMonth
                )
            )
        }
        
        return results
    }
    
    private var maxY: Double {
        monthlyData
            .map { max($0.totalSpend, $0.impulsiveSpend, $0.income) }
            .max() ?? 1
    }
    
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }
}
