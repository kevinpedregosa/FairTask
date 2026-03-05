import SwiftUI

@main
struct FairTaskApp: App {
    @State private var projectManager = ProjectManager()
    @StateObject private var store = ProjectStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(projectManager)
                .environmentObject(store)
        }
    }
}
