import SwiftUI

struct ContentView: View {
    @Environment(ProjectManager.self) private var projectManager
    @State private var showingNewProject = false

    var body: some View {
        NavigationStack {
            Group {
                if projectManager.projects.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)

                        Text("No Projects Yet")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Create your first project to start managing tasks")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Create Project") {
                            showingNewProject = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(projectManager.projects) { project in
                            ProjectRowView(project: project)
                                .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            projectManager.deleteProjects(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("FairTask")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewProject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewProject) {
                NavigationStack {
                    CreateProjectView()
                }
            }
        }
    }
}

#Preview("Empty State") {
    ContentView()
        .environment(ProjectManager())
        .environmentObject(ProjectStore())
}
