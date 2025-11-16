import Foundation

enum PurchaseType: String, Codable, CaseIterable, Identifiable {
    case unnecessaryImpulse = "Unnecessary Impulse"
    case newMonthlyCharge = "New Monthly Charge"
    case necessary = "Necessary food or clothing"
    case misc = "Miscellaneous"
    var id: String { rawValue }
}

struct Purchase: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var amount: Double
    var type: PurchaseType
    var platform: String? // e.g., Instagram
    var note: String?
    var impulsive: Bool
}

struct IncomeItem: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var startDate: Date
}

enum PortfolioKind: String, Codable, CaseIterable, Identifiable {
    case savings = "Savings"
    case rothIRA = "Roth IRA"
    case indexFund = "Index Fund"
    case other = "Other Savings"
    var id: String { rawValue }
}

struct Portfolio: Identifiable, Codable {
    var id = UUID()
    var name: String
    var kind: PortfolioKind
    var monthlyContribution: Double
    var expectedAnnualReturn: Double // 0.06 = 6%
    var startYear: Int
}

struct LessonModule: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var progress: Double // 0...1
}

struct QuizQuestion: Identifiable, Codable {
    var id = UUID()
    var prompt: String
    var choices: [String]
    var answerIndex: Int
    var explanation: String
}

struct UserProfile: Codable {
    var isImmigrantFamily: Bool?
    var experienceLevel: Int? // 1..4
}
