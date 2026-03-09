import SwiftUI

struct ProjectDetailView: View {
    @Environment(ProjectManager.self) private var projectManager
    let project: Project

    @State private var showingNewTask = false
    @State private var showingNewMember = false

    var body: some View {
        List {
            Section("Team Overview") {
                if currentProject.members.isEmpty {
                    Text("No members yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(currentProject.members) { member in
                        MemberRowView(member: member, project: currentProject)
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
                    }
                }
            }
        }
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
