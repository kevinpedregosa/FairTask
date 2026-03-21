import SwiftUI

struct MemberDetailView: View {
    @Environment(ProjectManager.self) private var projectManager
    let member: TeamMember
    let project: Project
    @State private var showingEdit = false
    @State private var draftName = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentMember.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(currentMember.totalPoints) points")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress")
                        .font(.headline)

                    detailRow(label: "Current streak", value: "\(currentMember.currentStreak)")
                    detailRow(label: "Longest streak", value: "\(currentMember.longestStreak)")
                    detailRow(label: "Completed tasks", value: "\(currentMember.completedTasksCount)")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Assigned Tasks")
                        .font(.headline)

                    if tasksForMember.isEmpty {
                        Text("No tasks assigned.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tasksForMember) { task in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(formattedDate(for: task.dueDate))
                                    .font(.caption)
                                    .foregroundStyle(task.isCompleted ? .green : .red)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Member Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    draftName = currentMember.name
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                Form {
                    Section("Name") {
                        TextField("Member name", text: $draftName)
                    }
                }
                .navigationTitle("Edit Member")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingEdit = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            projectManager.updateMemberName(currentMember, in: currentProject, name: draftName)
                            showingEdit = false
                        }
                        .disabled(draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private var currentProject: Project {
        projectManager.projects.first { $0.id == project.id } ?? project
    }

    private var currentMember: TeamMember {
        currentProject.member(withId: member.id) ?? member
    }

    private var tasksForMember: [Task] {
        currentProject.tasksForMember(member.id)
    }

    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let member = TeamMember(
        name: "Jeff",
        totalPoints: 25,
        currentStreak: 2,
        longestStreak: 4,
        completedTasksCount: 5,
        onTimeCompletionsCount: 6
    )

    let task1 = Task(
        title: "Research Abstract",
        description: "Draft the summary and list sources.",
        dueDate: Date().addingTimeInterval(86_400 * 2),
        assignedToId: member.id
    )

    let task2 = Task(
        title: "Data Extraction",
        description: "Collect metrics from the API.",
        dueDate: Date().addingTimeInterval(86_400 * 3),
        assignedToId: member.id
    )

    let project = Project(name: "Test Project", members: [member], tasks: [task1, task2])

    return NavigationStack {
        MemberDetailView(member: member, project: project)
    }
    .environment({
        let manager = ProjectManager()
        manager.projects = [project]
        return manager
    }())
}
