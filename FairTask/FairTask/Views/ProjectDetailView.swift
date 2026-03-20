import SwiftUI

struct ProjectDetailView: View {
    @Environment(ProjectManager.self) private var projectManager
    @EnvironmentObject private var themeStore: ThemeStore
    let project: Project

    @State private var showingNewTask = false
    @State private var showingNewMember = false
    @State private var memberToDelete: TeamMember?
    @State private var taskToDelete: Task?

    var body: some View {
        Group {
#if os(iOS)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    sectionHeader("Team Overview")
                    teamSection

                    sectionHeader("All Tasks")
                    taskSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
#else
            List {
                Section("Team Overview") {
                    if currentProject.members.isEmpty {
                        Text("No members yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(currentProject.members) { member in
                            MemberRowView(member: member, project: currentProject)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        memberToDelete = member
                                    } label: {
                                        Label("Delete Member", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

                Section("All Tasks") {
                    if currentProject.tasks.isEmpty {
                        Text("No tasks yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(currentProject.tasks) { task in
                            TaskRowView(task: task, project: currentProject)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        taskToDelete = task
                                    } label: {
                                        Label("Delete Task", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
#endif
        }
        .background(
            LinearGradient(
                colors: [themeStore.color1, themeStore.color2],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(currentProject.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingNewMember = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }

                Button {
                    showingNewTask = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(currentProject.members.isEmpty)
            }
        }
        .sheet(isPresented: $showingNewMember) {
            NavigationStack {
                NewMemberView(project: currentProject)
            }
        }
        .sheet(isPresented: $showingNewTask) {
            NewTaskView(project: currentProject)
        }
        .confirmationDialog(
            "Delete Member?",
            isPresented: Binding(
                get: { memberToDelete != nil },
                set: { if !$0 { memberToDelete = nil } }
            )
        ) {
            if let memberToDelete {
                Button("Delete \(memberToDelete.name)", role: .destructive) {
                    projectManager.deleteMember(memberToDelete, in: currentProject)
                    self.memberToDelete = nil
                }
            }

            Button("Cancel", role: .cancel) {
                memberToDelete = nil
            }
        } message: {
            if let memberToDelete {
                Text("This will remove \(memberToDelete.name) and all tasks assigned to them.")
            }
        }
        .confirmationDialog(
            "Delete Task?",
            isPresented: Binding(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )
        ) {
            if let taskToDelete {
                Button("Delete \(taskToDelete.title)", role: .destructive) {
                    projectManager.deleteTask(taskToDelete, in: currentProject)
                    self.taskToDelete = nil
                }
            }

            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }
        } message: {
            if let taskToDelete {
                Text("This will remove \(taskToDelete.title).")
            }
        }
    }

    @ViewBuilder
    private var teamSection: some View {
        if currentProject.members.isEmpty {
            Text("No members yet")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 0) {
                ForEach(currentProject.members) { member in
                    MemberRowView(member: member, project: currentProject)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                memberToDelete = member
                            } label: {
                                Label("Delete Member", systemImage: "trash")
                            }
                        }
                        .padding(.vertical, 8)

                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    private var taskSection: some View {
        if currentProject.tasks.isEmpty {
            Text("No tasks yet")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 0) {
                ForEach(currentProject.tasks) { task in
                    TaskRowView(task: task, project: currentProject)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                taskToDelete = task
                            } label: {
                                Label("Delete Task", systemImage: "trash")
                            }
                        }
                        .padding(.vertical, 8)

                    Divider()
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }

    private var currentProject: Project {
        projectManager.projects.first { $0.id == project.id } ?? project
    }
}

#Preview {
    let member1 = TeamMember(
        name: "Alice Johnson",
        totalPoints: 30,
        currentStreak: 3,
        longestStreak: 3,
        completedTasksCount: 3,
        onTimeCompletionsCount: 3
    )
    let member2 = TeamMember(
        name: "Bob Smith",
        totalPoints: 15,
        currentStreak: 0,
        longestStreak: 1,
        completedTasksCount: 2,
        onTimeCompletionsCount: 1
    )

    let task1 = Task(
        title: "Design mockups",
        dueDate: Date().addingTimeInterval(86_400 * 2),
        assignedToId: member1.id
    )
    let task2 = Task(
        title: "Set up database",
        dueDate: Date().addingTimeInterval(-86_400),
        assignedToId: member2.id
    )
    let task3 = Task(
        title: "Write documentation",
        dueDate: Date(),
        assignedToId: member1.id,
        isCompleted: true,
        completedDate: Date()
    )

    let project = Project(
        name: "Mobile App Redesign",
        members: [member1, member2],
        tasks: [task1, task2, task3]
    )

    let manager = ProjectManager()
    manager.projects = [project]

    return NavigationStack {
        ProjectDetailView(project: project)
    }
    .environment(manager)
}
