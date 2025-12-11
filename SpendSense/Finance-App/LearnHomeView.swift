
import SwiftUI

struct QuizPayload: Identifiable {
    let id = UUID()
    let title: String
    let questions: [QuizQuestion]
}

struct LearnHomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showOnboarding = false
    @State private var practiceQuizPayload: QuizPayload?
    @State private var showPersonalizeAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    personalizeCard
                    learningModulesSection
                    if !store.lessons.isEmpty {
                        practiceQuizzesSection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Learn")
            .sheet(isPresented: $showOnboarding) { OnboardingQuiz() }
            .sheet(item: $practiceQuizPayload) { (payload: QuizPayload) in
                MiniQuizView(title: payload.title, questions: payload.questions)
            }
            .alert("Personalize your plan", isPresented: $showPersonalizeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Complete Personalize my plan to unlock quizzes tailored to you.")
            }
        }
    }
    
    private var personalizeCard: some View {
        VStack(spacing: 16) {
            Button {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                showOnboarding = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personalize my plan")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Create a personalized learning plan")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var learningModulesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Learning Modules")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                if !store.lessons.isEmpty {
                    Text("\(store.lessons.count) modules")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            if store.lessons.isEmpty {
                emptyModulesView
            } else {
                ForEach(store.lessons) { module in
                    NavigationLink(destination: LessonDetailView(module: module)) {
                        LessonModuleCard(module: module)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var emptyModulesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.5))
            VStack(spacing: 8) {
                Text("No modules yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("Personalize your plan to unlock tailored learning modules")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal)
    }
    
    private var practiceQuizzesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Practice Quizzes")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(store.lessons) { lesson in
                    quizButton(for: lesson)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func quizButton(for lesson: LessonModule) -> some View {
        Button {
            guard store.profile.hasPersonalizedPlan == true else {
                showPersonalizeAlert = true
                return
            }
            var quiz = QuizContent.moduleQuestions(for: lesson.title)
            guard !quiz.isEmpty else { return }
            
            // Shuffle the answer choices for each question
            quiz = quiz.withShuffledChoices()
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            practiceQuizPayload = QuizPayload(title: lesson.title, questions: quiz)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quiz: \(lesson.title)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if QuizContent.moduleQuestions(for: lesson.title).isEmpty {
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Test your knowledge")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if !QuizContent.moduleQuestions(for: lesson.title).isEmpty {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "clock.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .disabled(QuizContent.moduleQuestions(for: lesson.title).isEmpty)
    }
}

struct LessonModuleCard: View {
    let module: LessonModule
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 60, height: 60)
                Circle()
                    .trim(from: 0, to: module.progress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: module.progress)
                
                if module.progress >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                } else {
                    Text("\(Int(module.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(progressColor)
                }
            }
            
            // Module info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(module.title)
                        .font(.headline)
                    Spacer()
                    if module.progress >= 1.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                
                Text(module.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                // Progress bar
                ProgressView(value: module.progress)
                    .tint(progressColor)
                    .frame(height: 4)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private var progressColor: Color {
        if module.progress >= 1.0 {
            return .green
        } else if module.progress >= 0.5 {
            return .blue
        } else {
            return .orange
        }
    }
}

struct OnboardingQuiz: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var isImmigrant: Bool = false
    @State private var experienceLevel: Int = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                Toggle("Are you or your immediate family immigrants?", isOn: $isImmigrant)
                } header: {
                    Text("Background")
                } footer: {
                    Text("This helps us provide relevant information about U.S. tax and financial systems.")
                }
                
                Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your experience level")
                    Picker("Experience level", selection: $experienceLevel) {
                        ForEach(1...4, id: \.self) { value in
                            Text("Level \(value)")
                                .tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(levelDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                } header: {
                    Text("Experience Level")
                } footer: {
                    Text("Select the level that best matches your current knowledge of personal finance.")
                }
            }
            .navigationTitle("Personalize my plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        persistProfile()
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var levelDescription: String {
        switch experienceLevel {
        case 1: return "Level 1 • Just starting out"
        case 2: return "Level 2 • Building confidence"
        case 3: return "Level 3 • Comfortable with key ideas"
        default: return "Level 4 • Ready to optimize"
        }
    }
    
    private func persistProfile() {
        store.profile.isImmigrantFamily = isImmigrant
        store.profile.experienceLevel = experienceLevel
        store.profile.hasPersonalizedPlan = true
        tailorModules()
        store.save()
    }

    func tailorModules() {
        // Simple rule-based tailoring
        store.lessons.removeAll()
        if store.profile.isImmigrantFamily == true || (store.profile.experienceLevel ?? 1) <= 2 {
            store.lessons.append(LessonModule(title: "Tax Basics", description: "Bullet points on policies and filing.", progress: 0))
            store.lessons.append(LessonModule(title: "Budgeting for U.S. Rent", description: "Rent by location, % income.", progress: 0))
        }
        store.lessons.append(LessonModule(title: "Understanding Credit", description: "Building credit; impacts car/home buying.", progress: 0))
    }
}

struct LessonDetailView: View {
    @EnvironmentObject var store: AppStore
    @State var module: LessonModule
    @State private var quizPayload: QuizPayload?
    @State private var showPersonalizeAlert = false
    @State private var monthlyIncomeInput: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Progress indicator
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(module.progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: module.progress)
                        .tint(.accentColor)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Description with better formatting
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.headline)
                    Text(module.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // Real-world examples section
                if let examples = realWorldExamples(for: module.title) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text("Real-World Examples")
                                .font(.headline)
                        }
                        ForEach(examples, id: \.self) { example in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(example)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Rent affordability calculator for Budgeting for U.S. Rent
                if module.title == "Budgeting for U.S. Rent" {
                    rentAffordabilitySection
                }
                
                // Key terms section
                if let terms = keyTerms(for: module.title) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundStyle(.blue)
                            Text("Key Terms")
                                .font(.headline)
                        }
                        ForEach(terms, id: \.term) { term in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(term.term)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(term.definition)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        guard let level = store.profile.experienceLevel else {
                            showPersonalizeAlert = true
                            return
                        }
                        guard store.profile.hasPersonalizedPlan == true else {
                            showPersonalizeAlert = true
                            return
                        }
                        let isImmigrant = store.profile.isImmigrantFamily ?? false
                        var quiz = QuizContent.personalizedModuleQuestions(for: module.title, isImmigrant: isImmigrant, level: level)
                        guard !quiz.isEmpty else {
                            showPersonalizeAlert = true
                            return
                        }
                        
                        // Shuffle the answer choices for each question
                        quiz = quiz.withShuffledChoices()
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        quizPayload = QuizPayload(title: module.title, questions: quiz)
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Take Mini-Quiz")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button {
                        if let idx = store.lessons.firstIndex(where: { $0.id == module.id }) {
                            var m = store.lessons[idx]
                            m.progress = min(1.0, (m.progress + 0.25))
                            store.lessons[idx] = m
                            module = m
                            store.save()
                            
                            let notificationFeedback = UINotificationFeedbackGenerator()
                            notificationFeedback.notificationOccurred(.success)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark Step Complete")
                            Spacer()
                        }
                        .padding()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            .padding()
        }
        .navigationTitle(module.title)
        .sheet(item: $quizPayload) { payload in
            MiniQuizView(title: payload.title, questions: payload.questions)
        }
        .alert("Personalize your plan", isPresented: $showPersonalizeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Complete Personalize my plan to unlock this module's tailored quiz experience.")
        }
    }
    
    private func realWorldExamples(for title: String) -> [String]? {
        switch title {
        case "Tax Basics":
            return [
                "If you earn $40,000/year, you might be in the 12% tax bracket for federal taxes.",
                "A tax credit reduces your tax bill dollar-for-dollar, while a deduction reduces your taxable income.",
                "Filing by April 15th helps you avoid penalties and interest charges."
            ]
        case "Budgeting for U.S. Rent":
            return [
                "A common rule is to spend no more than 30% of your monthly income on rent.",
                "If you earn $3,000/month, aim for rent around $900/month or less.",
                "Remember to budget for utilities, internet, and renter's insurance on top of rent."
            ]
        case "Understanding Credit":
            return [
                "Paying your credit card bill on time each month builds good credit history.",
                "A credit score above 700 can help you get better interest rates on loans.",
                "Using less than 30% of your available credit limit helps improve your score."
            ]
        default:
            return nil
        }
    }
    
    private func keyTerms(for title: String) -> [(term: String, definition: String)]? {
        switch title {
        case "Tax Basics":
            return [
                ("Tax Bracket", "The range of income taxed at a particular rate"),
                ("Tax Deduction", "An expense that reduces your taxable income"),
                ("Tax Credit", "An amount that directly reduces your tax bill"),
                ("W-2 Form", "A form showing your annual wages and taxes withheld")
            ]
        case "Budgeting for U.S. Rent":
            return [
                ("Security Deposit", "Money paid upfront to cover potential damages"),
                ("Lease", "A legal contract to rent a property for a set period"),
                ("Utilities", "Services like electricity, water, and gas"),
                ("Rent-to-Income Ratio", "Percentage of income spent on rent")
            ]
        case "Understanding Credit":
            return [
                ("Credit Score", "A number (300-850) that shows your creditworthiness"),
                ("Credit Report", "A detailed record of your credit history"),
                ("APR", "Annual Percentage Rate - the cost of borrowing money"),
                ("Credit Utilization", "Percentage of available credit you're using")
            ]
        default:
            return nil
        }
    }
    // Rent affordability calculator section
    private var rentAffordabilitySection: some View {
        let income = Double(monthlyIncomeInput) ?? 0
        let suggestedRent = income * 0.30
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(.blue)
                Text("What can I afford for rent?")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your monthly income to see what 30% looks like.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    TextField("Your monthly income", text: $monthlyIncomeInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            if income > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("30% of your income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(suggestedRent, format: .currency(code: "USD"))
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("A common rule of thumb is to keep rent at or below this amount each month.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            } else {
                Text("For example, if you earn $3,000/month, 30% would be about $900.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
}
