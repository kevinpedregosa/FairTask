import SwiftUI

@main
struct FairTaskApp: App {
    @State private var projectManager = ProjectManager()
    @StateObject private var store = ProjectStore()
    @StateObject private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(projectManager)
                .environmentObject(store)
                .environmentObject(themeStore)
        }
    }
}
