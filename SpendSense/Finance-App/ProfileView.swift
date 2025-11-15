import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        Form {
            Section("About You") {
                Text("Immigrant family: \(store.profile.isImmigrantFamily == true ? "Yes" : "No/Not set")")
                Text("Experience Level: \(store.profile.experienceLevel ?? 0)")
            }
            Section("Data") {
                Button("Export Demo Data (JSON)") {
                    store.save()
                }
                Button(role: .destructive, action: reset) { Text("Reset Demo Data") }
            }
        }
        .navigationTitle("Profile")
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
