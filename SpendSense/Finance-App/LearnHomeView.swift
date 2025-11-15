import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var showOnboarding = false

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
            }
            .navigationTitle("Learn")
            .sheet(isPresented: $showOnboarding) { OnboardingQuiz() }
        }
    }
}

struct OnboardingQuiz: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var isImmigrant: Bool = false
    @State private var experience: Double = 1

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Are you or your immediate family immigrants?", isOn: $isImmigrant)
                VStack(alignment: .leading) {
                    Text("Choose your experience level (1 low - 4 high)")
                    Slider(value: $experience, in: 1...4, step: 1)
                    Text("Level: \(Int(experience))").font(.caption)
                }
            }
            .navigationTitle("Onboarding Quiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.profile.isImmigrantFamily = isImmigrant
                        store.profile.experienceLevel = Int(experience)
                        tailorModules()
                        store.save()
                        dismiss()
                    }
                }
            }
        }
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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(module.description)
            Text("Mini-Game / Challenge placeholder").font(.footnote).foregroundStyle(.secondary)
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
    }
}
