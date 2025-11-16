import SwiftUI
import Charts

struct SpendingTrackerView: View {
    @EnvironmentObject var store: AppStore
    @State private var showLogPurchase = false
    @State private var showModifyIncome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SpendingChart(purchases: store.purchases)
                    .frame(height: 240)
                    .padding(.horizontal)

                Text("Current Debt:Income Ratio: \(debtToIncomeRatio, specifier: "%.2f")")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Log a new purchase") { showLogPurchase = true }
                        .buttonStyle(.borderedProminent)
                    Button("Modify monthly income") { showModifyIncome = true }
                        .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("2025 Spending Tracker")
            .sheet(isPresented: $showLogPurchase) { LogPurchaseView() }
            .sheet(isPresented: $showModifyIncome) { ModifyIncomeView() }
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
    let monthsBack: Int = 6

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
            }
            
            ForEach(data) { point in
                LineMark(
                    x: .value("Month", point.label),
                    y: .value("Amount", point.impulsiveSpend)
                )
                .symbol(.circle)
                .foregroundStyle(by: .value("Series", "Unnecessary Impulse"))
            }
        }
        .chartYAxisLabel("$ per month")
        .chartYScale(domain: 0...(maxY * 1.1))
        .chartForegroundStyleScale([
            "Total Spending": Color.accentColor,
            "Unnecessary Impulse": Color.red
        ])
        .chartLegend(position: .bottom)
    }
    
    private struct MonthlySummary: Identifiable {
        let id = UUID()
        let monthStart: Date
        let label: String
        let totalSpend: Double
        let impulsiveSpend: Double
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
            
            results.append(
                MonthlySummary(
                    monthStart: monthStart,
                    label: label,
                    totalSpend: totalSpend,
                    impulsiveSpend: impulsiveSpend
                )
            )
        }
        
        return results
    }
    
    private var maxY: Double {
        monthlyData
            .map { max($0.totalSpend, $0.impulsiveSpend) }
            .max() ?? 1
    }
    
    private var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        return df
    }
}
