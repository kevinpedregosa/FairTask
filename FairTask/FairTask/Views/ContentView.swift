import SwiftUI

struct ContentView: View {
    @Environment(ProjectManager.self) private var projectManager
    @EnvironmentObject private var themeStore: ThemeStore
    @State private var showingNewProject = false
    @State private var projectToDelete: Project?
    @State private var selectedProject: Project?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [themeStore.color1, themeStore.color2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

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

                            Button {
                                themeStore.randomize()
                            } label: {
                                Text("Change Color")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(projectManager.projects) { project in
                                Button {
                                    selectedProject = project
                                } label: {
                                    ProjectRowView(project: project)
                                        .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
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

                            Section {
                                Button {
                                    themeStore.randomize()
                                } label: {
                                    Text("Change Color")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
#if os(iOS)
                        .scrollContentBackground(.hidden)
#endif
                    }
                }
            }
            .navigationTitle("FairTask")
            .navigationDestination(item: $selectedProject) { project in
                ProjectDetailView(project: project)
            }
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
