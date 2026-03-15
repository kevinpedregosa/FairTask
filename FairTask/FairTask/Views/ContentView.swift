import SwiftUI

struct ContentView: View {
    @Environment(ProjectManager.self) private var projectManager
    @State private var showingNewProject = false
    @State private var projectToDelete: Project?

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
                            NavigationLink {
                                ProjectDetailView(project: project)
                            } label: {
                                ProjectRowView(project: project)
                                    .padding(.vertical, 4)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    projectToDelete = project
                                } label: {
                                    Label("Delete Project", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    projectToDelete = project
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            projectManager.deleteProjects(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("FairTask")
            .confirmationDialog(
                "Delete Project?",
                isPresented: Binding(
                    get: { projectToDelete != nil },
                    set: { if !$0 { projectToDelete = nil } }
                )
            ) {
                if let projectToDelete {
                    Button("Delete \(projectToDelete.name)", role: .destructive) {
                        deleteProject(projectToDelete)
                        self.projectToDelete = nil
                    }
                }

                Button("Cancel", role: .cancel) {
                    projectToDelete = nil
                }
            } message: {
                if let projectToDelete {
                    Text("This will remove \(projectToDelete.name) and all of its tasks.")
                }
            }
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
                NewProjectView()
            }
        }
    }

    private func deleteProject(_ project: Project) {
        guard let index = projectManager.projects.firstIndex(where: { $0.id == project.id }) else { return }
        projectManager.deleteProjects(at: IndexSet(integer: index))
    }
}

#Preview("Empty State") {
    ContentView()
        .environment(ProjectManager())
        .environmentObject(ProjectStore())
}
