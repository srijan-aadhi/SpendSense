import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showOnboarding = false
    @State private var practiceQuizPayload: QuizPayload?
    @State private var showPersonalizeAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Personalize my plan") { showOnboarding = true }
                }
                Section("Modules") {
                    ForEach(store.lessons) { m in
                        NavigationLink(destination: LessonDetailView(module: m)) {
                            VStack(alignment: .leading) {
                                Text(m.title).font(.headline)
                                ProgressView(value: m.progress)
                            }
                        }
                    }
                }
                
                Section("Practice quizzes") {
                    ForEach(store.lessons) { lesson in
                        Button {
                            guard store.profile.hasPersonalizedPlan == true else {
                                showPersonalizeAlert = true
                                return
                            }
                            let quiz = QuizContent.moduleQuestions(for: lesson.title)
                            guard !quiz.isEmpty else { return }
                            practiceQuizPayload = QuizPayload(title: lesson.title, questions: quiz)
                        } label: {
                            Label("Quiz: \(lesson.title)", systemImage: "questionmark.circle")
                        }
                        .disabled(QuizContent.moduleQuestions(for: lesson.title).isEmpty)
                    }
                }
            }
            .navigationTitle("Learn")
            .sheet(isPresented: $showOnboarding) { OnboardingQuiz() }
            .sheet(item: $practiceQuizPayload) { payload in
                MiniQuizView(title: payload.title, questions: payload.questions)
            }
            .alert("Personalize your plan", isPresented: $showPersonalizeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Complete “Personalize my plan” to unlock quizzes tailored to you.")
            }
        }
    }
}

struct OnboardingQuiz: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var isImmigrant: Bool = false
    @State private var experienceLevel: Int = 1
    @State private var personalizedQuizPayload: QuizPayload?

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Are you or your immediate family immigrants?", isOn: $isImmigrant)
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
                
                Section("Personalized quiz deck") {
                    Text("Build a quiz based on your selections to lock in the most relevant concepts.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Start personalized quiz") {
                        persistProfile()
                        let quiz = QuizContent.personalizedDeck(isImmigrant: isImmigrant, level: experienceLevel)
                        guard !quiz.isEmpty else { return }
                        personalizedQuizPayload = QuizPayload(title: "Personalized Plan", questions: quiz)
                    }
                }
            }
            .navigationTitle("Onboarding Quiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        persistProfile()
                        dismiss()
                    }
                }
            }
            .sheet(item: $personalizedQuizPayload) { payload in
                MiniQuizView(title: payload.title, questions: payload.questions)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(module.description)
            Button("Take mini-quiz") {
                guard let level = store.profile.experienceLevel else {
                    showPersonalizeAlert = true
                    return
                }
                guard store.profile.hasPersonalizedPlan == true else {
                    showPersonalizeAlert = true
                    return
                }
                let isImmigrant = store.profile.isImmigrantFamily ?? false
                let quiz = QuizContent.personalizedModuleQuestions(for: module.title, isImmigrant: isImmigrant, level: level)
                guard !quiz.isEmpty else {
                    showPersonalizeAlert = true
                    return
                }
                quizPayload = QuizPayload(title: module.title, questions: quiz)
            }
            .buttonStyle(.borderedProminent)
            ProgressView(value: module.progress)
            Button("Mark step complete") {
                if let idx = store.lessons.firstIndex(where: { $0.id == module.id }) {
                    var m = store.lessons[idx]
                    m.progress = min(1.0, (m.progress + 0.25))
                    store.lessons[idx] = m
                    module = m
                    store.save()
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(module.title)
        .sheet(item: $quizPayload) { payload in
            MiniQuizView(title: payload.title, questions: payload.questions)
        }
        .alert("Personalize your plan", isPresented: $showPersonalizeAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Complete “Personalize my plan” to unlock this module’s tailored quiz experience.")
        }
    }
}

struct QuizPayload: Identifiable {
    let id = UUID()
    let title: String
    let questions: [QuizQuestion]
}
