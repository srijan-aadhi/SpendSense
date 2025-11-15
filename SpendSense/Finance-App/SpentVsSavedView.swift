import SwiftUI
import Charts

struct SpentVsSavedView: View {
    @EnvironmentObject var store: AppStore
    @State private var amount: Double = 100
    @State private var years: Double = 5
    @State private var optionRate: Double = 0.07 // default index fund

    var body: some View {
        Form {
            Section("Select Purchase") {
                Picker("From Tracker", selection: $amount) {
                    ForEach(store.purchases) { p in
                        Text("$\(p.amount, specifier: "%.2f") • \(p.type.rawValue)").tag(p.amount)
                    }
                }
                Stepper("Or Custom: $\(amount, specifier: "%.0f")", value: $amount, in: 0...10000, step: 10)
            }
            Section("Investment Option") {
                Picker("Option", selection: $optionRate) {
                    Text("Roth IRA (7%)").tag(0.07)
                    Text("Index Fund (6%)").tag(0.06)
                    Text("Savings (2%)").tag(0.02)
                }
                Stepper("Time Horizon: \(Int(years)) years", value: $years, in: 1...40)
            }
            Section("Comparison") {
                let result = Finance.spentVsSaved(spent: amount, annualRate: optionRate, years: years)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Spent Today").font(.caption)
                        Text("$\(result.spent, specifier: "%.2f")").font(.title3)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("If Invested").font(.caption)
                        Text("$\(result.wouldBe, specifier: "%.2f")").font(.title3)
                    }
                }
                ComparisonChart(spent: result.spent, wouldBe: result.wouldBe)
                    .frame(height: 220)
                Text(suggestionText(result: result))
                    .font(.footnote)
            }
        }
        .navigationTitle("Spent vs Saved")
    }

    func suggestionText(result: (spent: Double, wouldBe: Double)) -> String {
        if result.wouldBe > result.spent * 1.5 {
            return "Tip: Try auto-transferring 10% of monthly income into this option to build momentum."
        } else {
            return "Tip: For short horizons, prioritize high-interest debt payoff and emergency fund."
        }
    }
}

struct ComparisonChart: View {
    var spent: Double
    var wouldBe: Double
    var body: some View {
        Chart {
            BarMark(x: .value("Type", "Spent"), y: .value("Amount", spent))
            BarMark(x: .value("Type", "If Invested"), y: .value("Amount", wouldBe))
        }
    }
}
