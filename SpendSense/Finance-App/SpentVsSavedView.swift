import SwiftUI
import Charts

struct SpentVsSavedView: View {
    @EnvironmentObject var store: AppStore
    @State private var amount: Double = 100
    @State private var years: Double = 5
    @State private var optionRate: Double = 0.07 // default index fund

    @State private var showHelp = false
    
    var body: some View {
        Form {
            Section {
                Picker("From Tracker", selection: $amount) {
                    ForEach(store.purchases) { p in
                        Text("$\(p.amount, specifier: "%.2f") • \(p.type.rawValue)").tag(p.amount)
                    }
                }
                Stepper("Or Custom: $\(amount, specifier: "%.0f")", value: $amount, in: 0...10000, step: 10)
            } header: {
                HStack {
                    Text("Select Purchase")
                    Spacer()
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                    }
                }
            } footer: {
                Text("Compare what you spent today with what it could be worth if invested instead.")
            }
            
            Section {
                Picker("Option", selection: $optionRate) {
                    Text("Roth IRA (7%)").tag(0.07)
                    Text("Index Fund (6%)").tag(0.06)
                    Text("Savings Account (2%)").tag(0.02)
                }
                Stepper("Time Horizon: \(Int(years)) years", value: $years, in: 1...40)
            } header: {
                Text("Investment Option")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Roth IRA: Tax-free growth for retirement (typical 7% return)")
                    Text("• Index Fund: Diversified stock market investment (typical 6% return)")
                    Text("• Savings Account: Low-risk, low-return option (typical 2% return)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Section {
                let result = Finance.spentVsSaved(spent: amount, annualRate: optionRate, years: years)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Spent Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(result.spent, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("If Invested")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("$\(result.wouldBe, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.vertical, 8)
                
                ComparisonChart(spent: result.spent, wouldBe: result.wouldBe)
                    .frame(height: 220)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("Tip")
                            .font(.headline)
                    }
                    Text(suggestionText(result: result))
                        .font(.subheadline)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } header: {
                Text("Comparison")
            }
        }
        .navigationTitle("Spent vs Saved")
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
                title: "Spent vs Saved",
                content: """
                This tool helps you understand the opportunity cost of spending money today versus investing it.
                
                **How it works:**
                • Select a purchase amount from your tracker or enter a custom amount
                • Choose an investment option and time horizon
                • See how much that money could grow if invested instead
                
                **Real-world example:**
                If you spend $100 today on something unnecessary, that's $100 gone. But if you invested that same $100 in a Roth IRA at 7% annual return for 10 years, it could grow to about $197.
                
                **Key takeaway:**
                Small purchases add up. Understanding the future value of money helps you make more informed spending decisions.
                """
            )
        }
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
    @State private var animateBars = false
    
    var body: some View {
        Chart {
            BarMark(x: .value("Type", "Spent"), y: .value("Amount", spent))
                .foregroundStyle(Color.red.opacity(0.7))
                .cornerRadius(8)
            BarMark(x: .value("Type", "If Invested"), y: .value("Amount", wouldBe))
                .foregroundStyle(Color.green.opacity(0.7))
                .cornerRadius(8)
        }
        .opacity(animateBars ? 1.0 : 0.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animateBars)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateBars = true
            }
        }
        .onChange(of: spent) { oldValue, newValue in
            animateBars = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateBars = true
                }
            }
        }
        .onChange(of: wouldBe) { oldValue, newValue in
            animateBars = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateBars = true
                }
            }
        }
    }
}
