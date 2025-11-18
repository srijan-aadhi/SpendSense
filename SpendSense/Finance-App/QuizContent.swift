import Foundation

enum QuizContent {
    static func moduleQuestions(for title: String) -> [QuizQuestion] {
        switch title {
        case "Tax Basics":
            return [
                QuizQuestion(
                    prompt: "Which form do most employees receive to report wages for federal taxes?",
                    choices: ["W-2", "1040-ES", "Schedule C", "1099-B"],
                    answerIndex: 0,
                    explanation: "Most salaried or hourly workers receive a W-2 from their employer each year."
                ),
                QuizQuestion(
                    prompt: "What is the standard deduction primarily used for?",
                    choices: [
                        "Reducing taxable income",
                        "Lowering credit card interest",
                        "Calculating FICA taxes",
                        "Paying state tax refunds"
                    ],
                    answerIndex: 0,
                    explanation: "The standard deduction lowers your taxable income before rates are applied."
                ),
                QuizQuestion(
                    prompt: "Which deadline applies to federal tax returns in most years?",
                    choices: ["April 15", "June 30", "September 1", "December 31"],
                    answerIndex: 0,
                    explanation: "Federal returns are typically due April 15 unless the date falls on a weekend/holiday."
                )
            ]
        case "Budgeting for U.S. Rent":
            return [
                QuizQuestion(
                    prompt: "A common rule suggests housing should stay below what percent of take-home pay?",
                    choices: ["30%", "45%", "55%", "70%"],
                    answerIndex: 0,
                    explanation: "Keeping housing near 30% helps leave room for savings and other bills."
                ),
                QuizQuestion(
                    prompt: "Which cost is usually due upfront with a new lease?",
                    choices: ["Security deposit", "Gym membership", "401(k) contribution", "Credit card annual fee"],
                    answerIndex: 0,
                    explanation: "Most landlords require a refundable security deposit at move-in."
                ),
                QuizQuestion(
                    prompt: "What does renters insurance primarily cover?",
                    choices: ["Personal belongings & liability", "Building repairs", "Mortgage payments", "HOA dues"],
                    answerIndex: 0,
                    explanation: "Renters insurance protects your belongings and offers liability coverage."
                )
            ]
        case "Understanding Credit":
            return [
                QuizQuestion(
                    prompt: "Which factor has the greatest weight in a typical FICO score?",
                    choices: ["Payment history", "Credit mix", "New credit", "Age of your pets"],
                    answerIndex: 0,
                    explanation: "On-time payments are the largest portion of a FICO score."
                ),
                QuizQuestion(
                    prompt: "Keeping credit utilization below which threshold is generally recommended?",
                    choices: ["30%", "60%", "85%", "100%"],
                    answerIndex: 0,
                    explanation: "Staying below 30% of available credit signals responsible usage."
                ),
                QuizQuestion(
                    prompt: "What happens when you only make the minimum payment on a credit card?",
                    choices: [
                        "You pay more interest over time",
                        "Your interest rate drops to zero",
                        "Your credit score immediately jumps 100 points",
                        "Your account closes automatically"
                    ],
                    answerIndex: 0,
                    explanation: "Minimums keep the account current but increase total interest costs."
                )
            ]
        default:
            return []
        }
    }
    
    static func personalizedDeck(isImmigrant: Bool, level: Int) -> [QuizQuestion] {
        let experienceLabel = level <= 2 ? "beginner" : "advanced"
        var deck: [QuizQuestion] = []
        
        if isImmigrant {
            deck.append(
                QuizQuestion(
                    prompt: "Which document is commonly needed to start a U.S. job?",
                    choices: ["Social Security number", "Landlord reference", "College diploma", "Passport from any country"],
                    answerIndex: 0,
                    explanation: "Employers use your Social Security number to report income and taxes."
                )
            )
            deck.append(
                QuizQuestion(
                    prompt: "How soon should new residents apply for a Social Security number after arrival?",
                    choices: ["Within a few weeks", "After five years", "Only before leaving the U.S.", "Never"],
                    answerIndex: 0,
                    explanation: "Applying within weeks keeps work and banking plans on track."
                )
            )
        } else {
            deck.append(
                QuizQuestion(
                    prompt: "What is a good first step toward building savings?",
                    choices: ["Automate transfers on payday", "Spend first and save leftovers", "Ignore employer benefits", "Delay budgeting"],
                    answerIndex: 0,
                    explanation: "Automations make saving consistent and less reliant on willpower."
                )
            )
            deck.append(
                QuizQuestion(
                    prompt: "Which account often offers tax advantages for retirement?",
                    choices: ["Roth IRA", "Checking account", "Daily cash jar", "Airline miles"],
                    answerIndex: 0,
                    explanation: "Roth IRAs grow tax-free and withdrawals in retirement are tax-free."
                )
            )
        }
        
        if experienceLabel == "beginner" {
            deck.append(
                QuizQuestion(
                    prompt: "What should you track first when building a budget?",
                    choices: ["Needs vs wants", "Stock splits", "Vacation souvenirs", "Crypto mining rigs"],
                    answerIndex: 0,
                    explanation: "Understanding essential vs discretionary costs keeps spending grounded."
                )
            )
        } else {
            deck.append(
                QuizQuestion(
                    prompt: "Which move helps improve a thin credit file quickly?",
                    choices: [
                        "Becoming an authorized user on a seasoned account",
                        "Closing all credit cards",
                        "Applying for ten cards in one day",
                        "Maxing every card every month"
                    ],
                    answerIndex: 0,
                    explanation: "Authorized users benefit from the primary account holder's history."
                )
            )
        }
        
        deck.append(
            QuizQuestion(
                prompt: "Level \(level) means you consider yourself a \(experienceLabel). What’s your next best step?",
                choices: [
                    "Review the curated lessons and complete the quiz deck",
                    "Skip learning entirely",
                    "Only read headlines",
                    "Wait a few years before planning"
                ],
                answerIndex: 0,
                explanation: "Pairing lessons with quizzes reinforces progress tailored to you."
            )
        )
        
        return deck
    }
    
    static func personalizedModuleQuestions(for title: String, isImmigrant: Bool, level: Int) -> [QuizQuestion] {
        let persona = isImmigrant ? "newcomer to the U.S." : "U.S.-based earner"
        let focus = level <= 2 ? "foundation" : "optimization"
        
        func scenarioPrompt(_ base: String) -> String {
            "\(base) (You identified as a \(persona) working on \(focus) skills.)"
        }
        
        switch title {
        case "Tax Basics":
            return [
                QuizQuestion(
                    prompt: scenarioPrompt("Which identification number lets you file taxes and open most bank accounts?"),
                    choices: ["Social Security number", "Student ID", "Transit pass", "Library card"],
                    answerIndex: 0,
                    explanation: "Linking income to a Social Security number (or ITIN) keeps paychecks and returns on track."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("You received both a W-2 and a 1099 form. What should you do when filing?"),
                    choices: [
                        "Report income from both forms",
                        "Ignore the 1099",
                        "File separate returns for each form",
                        "Only submit the form with the higher amount"
                    ],
                    answerIndex: 0,
                    explanation: "All taxable income must be included—use both documents inside a single return."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("Level \(level) learners are reviewing refunds. What happens if you withhold more than you owe?"),
                    choices: ["You receive the excess as a refund", "You’re charged a penalty", "Your employer keeps the extra money", "You must refile next year"],
                    answerIndex: 0,
                    explanation: "Extra withholding is returned once the IRS processes your return."
                )
            ]
        case "Budgeting for U.S. Rent":
            return [
                QuizQuestion(
                    prompt: scenarioPrompt("A landlord asks for proof of income. Which document best supports your application?"),
                    choices: ["Recent pay stubs or offer letter", "Store loyalty card", "Gym contract", "Travel itinerary"],
                    answerIndex: 0,
                    explanation: "Verified earnings—via pay stubs or offers—demonstrate ability to cover rent."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("You set rent to 30% of take-home pay. If monthly net income is $3,600, what’s your rent ceiling?"),
                    choices: ["$1,080", "$1,800", "$2,400", "$3,000"],
                    answerIndex: 0,
                    explanation: "30% of $3,600 equals $1,080, which keeps room for savings and transport."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("Level \(level) planners want to build credit. Which recurring bill could you report through a rent-reporting service?"),
                    choices: ["Your monthly rent payments", "Streaming subscriptions", "Coffee purchases", "Ride-share tips"],
                    answerIndex: 0,
                    explanation: "Many services now add on-time rent data to your credit files."
                )
            ]
        case "Understanding Credit":
            return [
                QuizQuestion(
                    prompt: scenarioPrompt("After arriving in the U.S., which first step helps establish credit?"),
                    choices: ["Secured credit card or credit-builder loan", "Paying bills with cash only", "Avoiding any accounts", "Opening ten cards immediately"],
                    answerIndex: 0,
                    explanation: "Secured products build payment history while keeping limits manageable."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("Your utilization sits at 65%. What action reduces it the fastest?"),
                    choices: [
                        "Pay down balances before the statement closes",
                        "Apply for more store cards",
                        "Increase spending to 90%",
                        "Ignore balances until they charge off"
                    ],
                    answerIndex: 0,
                    explanation: "Lowering balances is the direct way to reduce utilization."
                ),
                QuizQuestion(
                    prompt: scenarioPrompt("Level \(level) goal-setters review credit reports. How often can you get a free copy from each bureau at AnnualCreditReport.com?"),
                    choices: ["Every 12 months", "Every 24 hours", "Only once in a lifetime", "Never"],
                    answerIndex: 0,
                    explanation: "Federal law guarantees one free report from each major bureau every year."
                )
            ]
        default:
            return []
        }
    }
}

