import SwiftUI

struct ProjectRowView: View {
    let project: Project

    private var completedTasksCount: Int {
        project.tasks.filter(\.isCompleted).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label("\(project.members.count) members", systemImage: "person.2.fill")
                Label("\(project.tasks.count) tasks", systemImage: "list.bullet")
                Label("\(completedTasksCount)/\(project.tasks.count)", systemImage: "checkmark.circle.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let member = TeamMember(name: "Test User")
    let task1 = Task(title: "Task 1", dueDate: Date(), assignedToId: member.id, isCompleted: true, completedDate: Date())
    let task2 = Task(title: "Task 2", dueDate: Date(), assignedToId: member.id)
    let project = Project(name: "Sample Project", members: [member], tasks: [task1, task2])

    return ProjectRowView(project: project)
        .padding()
}
