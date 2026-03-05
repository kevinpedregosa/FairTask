import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ProjectStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        CreateProjectView()
                    } label: {
                        Label("Create New Project", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                }

                Section("Saved Projects") {
                    if store.projects.isEmpty {
                        Text("No saved projects yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.projects) { project in
                            NavigationLink(project.name) {
                                ProjectDashboardView(projectID: project.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("FairTask")
        }
    }
}
