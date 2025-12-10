import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Immigrant Family")
                    Spacer()
                    Text(store.profile.isImmigrantFamily == true ? "Yes" : "No/Not set")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Experience Level")
                    Spacer()
                    if let level = store.profile.experienceLevel {
                        Text("Level \(level)")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not set")
                            .foregroundStyle(.secondary)
                    }
                }
                if store.profile.hasPersonalizedPlan == true {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Personalized Plan Active")
                            .foregroundStyle(.green)
                    }
                }
            } header: {
                Text("About You")
            } footer: {
                Text("Your profile helps personalize your learning experience. Update it in the Learn tab.")
            }
            
            Section {
                Button {
                    store.save()
                    let notificationFeedback = UINotificationFeedbackGenerator()
                    notificationFeedback.notificationOccurred(.success)
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Demo Data (JSON)")
                    }
                }
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Demo Data")
                    }
                }
            } header: {
                Text("Data Management")
            } footer: {
                Text("Reset will restore sample data. This action cannot be undone.")
            }
        }
        .navigationTitle("Profile")
        .alert("Reset All Data?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                reset()
            }
        } message: {
            Text("This will delete all your purchases, income entries, portfolios, and progress. Sample data will be restored.")
        }
    }

    func reset() {
        store.purchases.removeAll()
        store.incomes.removeAll()
        store.portfolios.removeAll()
        store.lessons.removeAll()
        store.profile = UserProfile()
        store.seed()
        store.save()
    }
}
