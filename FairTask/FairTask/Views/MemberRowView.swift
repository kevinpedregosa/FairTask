import SwiftUI

struct MemberRowView: View {
    let member: TeamMember
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(member.name)
                    .font(.headline)

                if let badge = member.badge {
                    Text(badge)
                }

                Spacer()

                Text("\(member.totalPoints) pts")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }

            HStack(spacing: 16) {
                Label("\(tasksForMember.count) tasks", systemImage: "list.bullet")

                Label("\(member.currentStreak) streak", systemImage: "flame.fill")
                    .foregroundStyle(member.currentStreak > 0 ? .orange : .secondary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !tasksForMember.isEmpty {
                TaskStatusBar(tasks: tasksForMember)
            }
        }
        .padding(.vertical, 4)
    }

    private var tasksForMember: [Task] {
        project.tasksForMember(member.id)
    }
}

struct TaskStatusBar: View {
    let tasks: [Task]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tasks.prefix(8)) { task in
                Circle()
                    .fill(colorForTask(task))
                    .frame(width: 8, height: 8)
            }

            if tasks.count > 8 {
                Text("+\(tasks.count - 8)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func colorForTask(_ task: Task) -> Color {
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
}

#Preview {
    let memberId = UUID()
    let now = Date()
    let calendar = Calendar.current

    let task1 = Task(
        title: "Task 1",
        dueDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
        assignedToId: memberId,
        isCompleted: true,
        completedDate: now
    )

    let task2 = Task(
        title: "Task 2",
        dueDate: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
        assignedToId: memberId
    )

    let task3 = Task(
        title: "Task 3",
        dueDate: calendar.date(byAdding: .day, value: 2, to: now) ?? now,
        assignedToId: memberId
    )

    let tasks = [task1, task2, task3]

    let member = TeamMember(
        id: memberId,
        name: "Alice Johnson",
        totalPoints: 25,
        currentStreak: 2,
        longestStreak: 4,
        completedTasksCount: 5,
        onTimeCompletionsCount: 6,
        tasksAssigned: tasks,
        lastCompletedDate: now
    )

    let project = Project(name: "Test Project", members: [member], tasks: tasks)

    return MemberRowView(member: member, project: project)
        .padding()
}
