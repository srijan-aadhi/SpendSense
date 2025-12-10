import SwiftUI
import Charts

struct SavingsSimulatorHome: View {
    @EnvironmentObject var store: AppStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary card
                    if !store.portfolios.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total Portfolios")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(store.portfolios.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Monthly Total")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("$\(totalMonthlyContributions, specifier: "%.0f")")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Portfolios section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Savings Portfolios")
                                .font(.headline)
                            Spacer()
                            Button {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                showAdd = true
                            } label: {
                                Label("Add Portfolio", systemImage: "plus.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                        
                        if store.portfolios.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                Text("No portfolios yet")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text("Create your first portfolio to start tracking savings growth")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(store.portfolios) { p in
                                NavigationLink(destination: PortfolioDetail(portfolio: p)) {
                                    PortfolioRowView(portfolio: p)
                                }
                            }
                        }
                    }
                    
                    // Spent vs Saved section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tools")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: SpentVsSavedView()) {
                            HStack {
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Spent vs Saved")
                                        .font(.headline)
                                    Text("Compare spending vs investing")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Savings Simulator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showAdd = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddPortfolioSheet() }
        }
    }
    
    private var totalMonthlyContributions: Double {
        store.portfolios.map { $0.monthlyContribution }.reduce(0, +)
    }
}

struct PortfolioRowView: View {
    let portfolio: Portfolio
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on portfolio type
            Image(systemName: iconForKind(portfolio.kind))
                .foregroundStyle(colorForKind(portfolio.kind))
                .font(.title3)
                .frame(width: 50, height: 50)
                .background(colorForKind(portfolio.kind).opacity(0.1))
                .clipShape(Circle())
            
            // Portfolio details
            VStack(alignment: .leading, spacing: 4) {
                Text(portfolio.name)
                    .font(.headline)
                Text(portfolio.kind.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Monthly contribution
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(portfolio.monthlyContribution, specifier: "%.0f")/mo")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(portfolio.expectedAnnualReturn * 100, specifier: "%.1f")% return")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func iconForKind(_ kind: PortfolioKind) -> String {
        switch kind {
        case .savings: return "banknote.fill"
        case .rothIRA: return "chart.line.uptrend.xyaxis"
        case .indexFund: return "chart.bar.fill"
        case .other: return "wallet.pass.fill"
        }
    }
    
    private func colorForKind(_ kind: PortfolioKind) -> Color {
        switch kind {
        case .savings: return .blue
        case .rothIRA: return .green
        case .indexFund: return .orange
        case .other: return .purple
        }
    }
}

struct PortfolioDetail: View {
    @EnvironmentObject var store: AppStore
    @State var portfolio: Portfolio
    @Environment(\.dismiss) private var dismiss
    @State private var years: Double = 5
    @State private var showHelp = false

    var body: some View {
        Form {
            Section {
                ProjectionChart(monthly: portfolio.monthlyContribution, annualRate: portfolio.expectedAnnualReturn, years: years)
                    .frame(height: 220)
                Stepper("Time Horizon: \(Int(years)) years", value: $years, in: 1...40)
            } header: {
                HStack {
                    Text("Projection")
                    Spacer()
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                    }
                }
            } footer: {
                Text("This projection shows how your savings could grow over time based on your monthly contributions and expected return rate.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Contribution")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Amount per month", value: $portfolio.monthlyContribution, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .padding(.top, 2)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Annual Rate of Return")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Rate (e.g. 0.07 for 7%)", value: $portfolio.expectedAnnualReturn, format: .number)
                        .keyboardType(.decimalPad)
                        .padding(.top, 2)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Portfolio Name")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextField("Name", text: $portfolio.name)
                        .padding(.top, 2)
                }
            } header: {
                Text("Settings")
            }
            
            Section {
                Button {
                    if let idx = store.portfolios.firstIndex(where: { $0.id == portfolio.id }) {
                        store.portfolios[idx] = portfolio
                        store.save()
                        
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                        
                        dismiss()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Label("Save Changes", systemImage: "checkmark.circle.fill")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(portfolio.name)
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
                title: "Savings Projection",
                content: """
                This projection shows how your savings could grow over time.
                
                **How it works:**
                • Enter how much you'll contribute each month
                • Set your expected annual return rate (e.g., 0.07 = 7%)
                • Adjust the time horizon to see different scenarios
                
                **Real-world example:**
                If you save $100/month in a Roth IRA with a 7% annual return:
                • After 10 years: ~$17,308
                • After 20 years: ~$52,338
                • After 30 years: ~$122,150
                
                **Important notes:**
                • Returns are not guaranteed and can vary
                • This is a simplified calculation (compound interest)
                • Consult a financial advisor for personalized advice
                """
            )
        }
    }
}

struct ProjectionChart: View {
    var monthly: Double
    var annualRate: Double
    var years: Double
    @State private var animateLine = false
    
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
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .chartXAxisLabel("Months")
        .chartYAxisLabel("Projected Balance ($)")
        .opacity(animateLine ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.2), value: animateLine)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animateLine = true
            }
        }
        .onChange(of: monthly) { oldValue, newValue in
            animateLine = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.9)) {
                    animateLine = true
                }
            }
        }
        .onChange(of: annualRate) { oldValue, newValue in
            animateLine = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.9)) {
                    animateLine = true
                }
            }
        }
        .onChange(of: years) { oldValue, newValue in
            animateLine = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.9)) {
                    animateLine = true
                }
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
