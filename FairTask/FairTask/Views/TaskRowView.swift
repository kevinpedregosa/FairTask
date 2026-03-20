import SwiftUI

struct TaskRowView: View {
    @Environment(ProjectManager.self) private var projectManager
    let task: Task
    let project: Project

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                projectManager.toggleTaskCompletion(task, in: project)
            } label: {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(task.isCompleted ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(task.isCompleted ? Color.green : Color.red, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)

                HStack {
                    if let member = project.member(withId: task.assignedToId) {
                        Text(member.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(task.isCompleted ? statusColor : .red)
                }
            }

            Spacer()

            Text("\(task.pointsWorth) points")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }

    private var statusText: String {
        switch task.status {
        case .completed:
            return "Completed"
        case .overdue:
            return "Overdue"
        case .dueToday:
            return "Due Today"
        case .upcoming:
            return "Upcoming"
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .completed:
            return .green
        case .overdue:
            return .red
        case .dueToday:
            return .orange
        case .upcoming:
            return .blue
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: task.dueDate)
    }
}

#Preview {
    let member = TeamMember(name: "Alice Johnson")
    let task1 = Task(
        title: "Design mockups",
        dueDate: Date().addingTimeInterval(86_400 * 2),
        assignedToId: member.id
    )
    let task2 = Task(
        title: "Set up database",
        dueDate: Date().addingTimeInterval(-86_400),
        assignedToId: member.id
    )
    let task3 = Task(
        title: "Code review",
        dueDate: Date().addingTimeInterval(-86_400 * 2),
        assignedToId: member.id,
        isCompleted: true,
        completedDate: Date()
    )
    let project = Project(name: "Test Project", members: [member], tasks: [task1, task2, task3])

    return VStack {
        TaskRowView(task: task1, project: project)
        Divider()
        TaskRowView(task: task2, project: project)
        Divider()
        TaskRowView(task: task3, project: project)
    }
    .environment(ProjectManager())
        .padding()
}
