import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showOnboarding = false
    @State private var showQuickQuiz = false
    @State private var quickQuizTitle = ""
    @State private var quickQuizQuestions: [QuizQuestion] = []

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
                            quickQuizTitle = lesson.title
                            quickQuizQuestions = QuizContent.moduleQuestions(for: lesson.title)
                            showQuickQuiz = true
                        } label: {
                            Label("Quiz: \(lesson.title)", systemImage: "questionmark.circle")
                        }
                        .disabled(QuizContent.moduleQuestions(for: lesson.title).isEmpty)
                    }
                }
            }
            .navigationTitle("Learn")
            .sheet(isPresented: $showOnboarding) { OnboardingQuiz() }
            .sheet(isPresented: $showQuickQuiz) {
                MiniQuizView(title: quickQuizTitle, questions: quickQuizQuestions)
            }
        }
    }
}

struct OnboardingQuiz: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var isImmigrant: Bool = false
    @State private var experience: Double = 1
    @State private var showTailoredQuiz = false
    @State private var tailoredQuestions: [QuizQuestion] = []

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Are you or your immediate family immigrants?", isOn: $isImmigrant)
                VStack(alignment: .leading) {
                    Text("Choose your experience level (1 low - 4 high)")
                    Slider(value: $experience, in: 1...4, step: 1)
                    Text("Level: \(Int(experience))").font(.caption)
                }
                
                Section("Personalized quiz deck") {
                    Text("Build a quiz based on your selections to lock in the most relevant concepts.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Start personalized quiz") {
                        persistProfile()
                        tailoredQuestions = QuizContent.personalizedDeck(isImmigrant: isImmigrant, level: Int(experience))
                        showTailoredQuiz = true
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
            .sheet(isPresented: $showTailoredQuiz) {
                MiniQuizView(title: "Personalized Plan", questions: tailoredQuestions)
            }
        }
    }
    
    private func persistProfile() {
        store.profile.isImmigrantFamily = isImmigrant
        store.profile.experienceLevel = Int(experience)
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
    @State private var showQuiz = false
    @State private var activeQuiz: [QuizQuestion] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(module.description)
            Button("Take mini-quiz") {
                activeQuiz = QuizContent.moduleQuestions(for: module.title)
                showQuiz = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(QuizContent.moduleQuestions(for: module.title).isEmpty)
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
        .sheet(isPresented: $showQuiz) {
            MiniQuizView(title: module.title, questions: activeQuiz)
        }
    }
}
