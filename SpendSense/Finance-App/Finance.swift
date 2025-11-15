import Foundation

struct Finance {
    /// Future value of monthly contribution at annual rate r over years
    static func futureValue(monthlyContribution: Double, annualRate: Double, years: Double) -> Double {
        let r = annualRate / 12.0
        let n = Int(years * 12.0)
        if r == 0 { return monthlyContribution * Double(n) }
        return monthlyContribution * (pow(1 + r, Double(n)) - 1) / r
    }

    /// Opportunity cost: amount spent today vs investing it for 'years'
    static func spentVsSaved(spent: Double, annualRate: Double, years: Double) -> (spent: Double, wouldBe: Double) {
        let wouldBe = spent * pow(1 + annualRate, years)
        return (spent, wouldBe)
    }
}
