import SwiftUI
import Charts

struct SpendingTrackerView: View {
    @EnvironmentObject var store: AppStore
    @State private var showLogPurchase = false
    @State private var showModifyIncome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SpendingChart(purchases: store.purchases, incomes: store.incomes)
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
    let incomes: [IncomeItem]

    var body: some View {
        Chart {
            ForEach(incomeSeries.indices, id: \.self) { i in
                LineMark(x: .value("Month", i), y: .value("Income", incomeSeries[i]))
                    .foregroundStyle(.green)
            }
            ForEach(spendSeries.indices, id: \.self) { i in
                LineMark(x: .value("Month", i), y: .value("Unnecessary Spending", spendSeries[i]))
                    .foregroundStyle(.red)
            }
        }
        .chartYAxisLabel("$ Amount")
    }

    // Simple cumulative series month-by-month for demo
    var spendSeries: [Double] {
        let sorted = purchases.sorted { $0.date < $1.date }
        var cum: Double = 0
        var buckets: [Double] = Array(repeating: 0, count: 12)
        let calendar = Calendar.current
        for p in sorted where p.type == .unnecessaryImpulse {
            let m = calendar.component(.month, from: p.date) - 1
            buckets[m] += p.amount
        }
        return buckets.map { cum += $0; return cum }
    }

    var incomeSeries: [Double] {
        var cum: Double = 0
        var buckets: [Double] = Array(repeating: 0, count: 12)
        let calendar = Calendar.current
        for inc in incomes {
            let m = calendar.component(.month, from: inc.startDate) - 1
            if m >= 0 && m < 12 { buckets[m] += inc.amount }
        }
        return buckets.map { cum += $0; return cum }
    }
}
