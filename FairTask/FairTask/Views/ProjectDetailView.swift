import SwiftUI
#if os(iOS)
import UIKit
#endif

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
            List {
                Section {
                    teamSection
                } header: {
                    sectionHeader("Team Overview")
                }

                Section {
                    taskSection
                } header: {
                    sectionHeader("All Tasks")
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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
            let members = currentProject.members
            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                let isFirst = index == 0
                let isLast = index == members.count - 1
                let cornerStyle: CardCornerStyle = {
                    switch (isFirst, isLast) {
                    case (true, true):
                        return .all
                    case (true, false):
                        return .top
                    case (false, true):
                        return .bottom
                    default:
                        return .none
                    }
                }()

                VStack(spacing: 0) {
                    MemberRowView(member: member, project: currentProject)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                memberToDelete = member
                            } label: {
                                Label("Delete Member", systemImage: "trash")
                            }
                        }
                        .overlay(alignment: .trailing) {
                            Button {
                                memberToDelete = member
                            } label: {
                                Image(systemName: "chevron.right")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.gray)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 20)
                        }
#if os(iOS)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                memberToDelete = member
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white.opacity(0.92))
#endif
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)

                    if index != members.count - 1 {
                        Divider()
                            .padding(.leading, 12)
                            .padding(.trailing, 12)
                    }
                }
                .background(
                    CardRowBackground(style: cornerStyle, radius: 24)
                        .fill(Color.white.opacity(0.96))
                        .padding(.horizontal, 12)
                )
                .overlay(
                    CardRowBackground(style: cornerStyle, radius: 24)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        .padding(.horizontal, 12)
                )
#if os(iOS)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
#endif
            }
        }
    }

    @ViewBuilder
    private var taskSection: some View {
        if currentProject.tasks.isEmpty {
            Text("No tasks yet")
                .foregroundStyle(.secondary)
        } else {
            let tasks = currentProject.tasks
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                let isFirst = index == 0
                let isLast = index == tasks.count - 1
                let cornerStyle: CardCornerStyle = {
                    switch (isFirst, isLast) {
                    case (true, true):
                        return .all
                    case (true, false):
                        return .top
                    case (false, true):
                        return .bottom
                    default:
                        return .none
                    }
                }()

                VStack(spacing: 0) {
                    TaskRowView(task: task, project: currentProject)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                taskToDelete = task
                            } label: {
                                Label("Delete Task", systemImage: "trash")
                            }
                        }
                        .overlay(alignment: .trailing) {
                            Button {
                                taskToDelete = task
                            } label: {
                                Image(systemName: "chevron.right")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.gray)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 20)
                        }
#if os(iOS)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                taskToDelete = task
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.white.opacity(0.92))
#endif
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)

                    if index != tasks.count - 1 {
                        Divider()
                            .padding(.leading, 12)
                            .padding(.trailing, 12)
                    }
                }
                .background(
                    CardRowBackground(style: cornerStyle, radius: 24)
                        .fill(Color.white.opacity(0.96))
                        .padding(.horizontal, 12)
                )
                .overlay(
                    CardRowBackground(style: cornerStyle, radius: 24)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        .padding(.horizontal, 12)
                )
#if os(iOS)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
#endif
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }

    private var currentProject: Project {
        projectManager.projects.first { $0.id == project.id } ?? project
    }
}

private struct CardRowBackground: Shape {
    var style: CardCornerStyle
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
#if os(iOS)
        let corners: UIRectCorner
        switch style {
        case .all:
            corners = .allCorners
        case .top:
            corners = [.topLeft, .topRight]
        case .bottom:
            corners = [.bottomLeft, .bottomRight]
        case .none:
            corners = []
        }
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
#else
        if style == .none {
            return Path(rect)
        }
        return Path(roundedRect: rect, cornerRadius: radius)
#endif
    }
}

private enum CardCornerStyle {
    case all
    case top
    case bottom
    case none
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
