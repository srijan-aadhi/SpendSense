import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            SpendingTrackerView()
                .tabItem { Label("Tracker", systemImage: "chart.line.uptrend.xyaxis") }
            SavingsSimulatorHome()
                .tabItem { Label("Simulator", systemImage: "arrow.left.arrow.right.circle") }
            LearnHomeView()
                .tabItem { Label("Learn", systemImage: "book.pages") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}
