import SwiftUI
import Charts

struct SavingsSimulatorHome: View {
    @EnvironmentObject var store: AppStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section("Current Savings Portfolios") {
                    ForEach(store.portfolios) { p in
                        NavigationLink(destination: PortfolioDetail(portfolio: p)) {
                            VStack(alignment: .leading) {
                                Text(p.name).font(.headline)
                                Text(p.kind.rawValue).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        store.portfolios.remove(atOffsets: indexSet)
                        store.save()
                    }
                }

                Section {
                    NavigationLink("Spent vs Saved", destination: SpentVsSavedView())
                }
            }
            .navigationTitle("Savings Growth Sim.")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) { Label("Add", systemImage: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddPortfolioSheet() }
        }
    }
}

struct PortfolioDetail: View {
    @EnvironmentObject var store: AppStore
    @State var portfolio: Portfolio
    @Environment(\.dismiss) private var dismiss
    @State private var years: Double = 5

    var body: some View {
        Form {
            Section("Projection") {
                ProjectionChart(monthly: portfolio.monthlyContribution, annualRate: portfolio.expectedAnnualReturn, years: years)
                    .frame(height: 220)
                Stepper("Time Horizon: \(Int(years)) years", value: $years, in: 1...40)
            }
            Section("Settings") {
                TextField("Monthly Contribution", value: $portfolio.monthlyContribution, format: .number)
                TextField("Annual Return (e.g. 0.07)", value: $portfolio.expectedAnnualReturn, format: .number)
                TextField("Name", text: $portfolio.name)
            }
            Section {
                Button("Save Changes") {
                    if let idx = store.portfolios.firstIndex(where: { $0.id == portfolio.id }) {
                        store.portfolios[idx] = portfolio
                        store.save()
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(portfolio.name)
    }
}

struct ProjectionChart: View {
    var monthly: Double
    var annualRate: Double
    var years: Double
    var body: some View {
        let months = Int(years * 12)
        let r = annualRate/12
        var values: [Double] = []
        var total: Double = 0
        for _ in 0..<months {
            total = total * (1+r) + monthly
            values.append(total)
        }
        return Chart {
            ForEach(values.indices, id: \.self) { i in
                LineMark(x: .value("Month", i), y: .value("Value", values[i]))
            }
        }
    }
}

struct AddPortfolioSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var kind: PortfolioKind = .savings
    @State private var name: String = "Savings"
    @State private var monthly: Double = 50
    @State private var annual: Double = 0.02

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $kind) {
                    ForEach(PortfolioKind.allCases) { k in Text(k.rawValue).tag(k) }
                }
                TextField("Name", text: $name)
                Stepper("Monthly: $\(monthly, specifier: "%.0f")", value: $monthly, in: 0...5000, step: 10)
                TextField("Annual Return", value: $annual, format: .number)
            }
            .navigationTitle("Add Portfolio")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.portfolios.append(Portfolio(name: name, kind: kind, monthlyContribution: monthly, expectedAnnualReturn: annual, startYear: Calendar.current.component(.year, from: Date())))
                        store.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
