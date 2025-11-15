import Foundation
import Combine
@MainActor
final class AppStore: ObservableObject {
    @Published var purchases: [Purchase] = []
    @Published var incomes: [IncomeItem] = []
    @Published var portfolios: [Portfolio] = []
    @Published var lessons: [LessonModule] = []
    @Published var profile = UserProfile()

    private let fm = FileManager.default
    private var dir: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    init() {
        load()
        if purchases.isEmpty && incomes.isEmpty && portfolios.isEmpty {
            seed()
            save()
        }
    }

    func seed() {
        incomes = [
            IncomeItem(amount: 1000, startDate: Date().addingTimeInterval(-120*86400)),
            IncomeItem(amount: 1200, startDate: Date().addingTimeInterval(-30*86400))
        ]
        purchases = [
            Purchase(date: Date().addingTimeInterval(-20*86400), amount: 49.99, type: .unnecessaryImpulse, platform: "Instagram", note: "LED lights ad", impulsive: true),
            Purchase(date: Date().addingTimeInterval(-10*86400), amount: 12.50, type: .necessary, platform: nil, note: "Groceries", impulsive: false)
        ]
        portfolios = [
            Portfolio(name: "Roth IRA", kind: .rothIRA, monthlyContribution: 100, expectedAnnualReturn: 0.07, startYear: 2019),
            Portfolio(name: "Savings", kind: .savings, monthlyContribution: 50, expectedAnnualReturn: 0.02, startYear: 2021)
        ]
        lessons = [
            LessonModule(title: "Tax Basics", description: "Understand filing, brackets, and credits.", progress: 0.0),
            LessonModule(title: "Budgeting for U.S. Rent", description: "Plan rent, utilities, and deposits.", progress: 0.0),
            LessonModule(title: "Understanding Credit", description: "Build credit and avoid pitfalls.", progress: 0.0)
        ]
    }

    // MARK: - Persistence
    func save() {
        save(purchases, name: "purchases.json")
        save(incomes, name: "incomes.json")
        save(portfolios, name: "portfolios.json")
        save(lessons, name: "lessons.json")
        save(profile, name: "profile.json")
    }

    private func save<T: Codable>(_ value: T, name: String) {
        do {
            let url = dir.appendingPathComponent(name)
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Save error", name, error)
        }
    }

    func load() {
        purchases = load("purchases.json") ?? []
        incomes = load("incomes.json") ?? []
        portfolios = load("portfolios.json") ?? []
        lessons = load("lessons.json") ?? []
        profile = load("profile.json") ?? UserProfile()
    }

    private func load<T: Codable>(_ name: String) -> T? {
        let url = dir.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
