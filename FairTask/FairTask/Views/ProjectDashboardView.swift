import SwiftUI

struct ProjectDashboardView: View {
    @EnvironmentObject private var store: ProjectStore

    let projectID: UUID

    var body: some View {
        Group {
            if let project = store.projects.first(where: { $0.id == projectID }) {
                List {
                    ForEach(project.members) { member in
                        Section {
                            DisclosureGroup {
                                if member.tasksAssigned.isEmpty {
                                    Text("No tasks assigned")
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(member.tasksAssigned) { task in
                                        taskRow(project: project, member: member, task: task)
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(member.name)
                                        .font(.headline)
                                    HStack {
                                        Text("\(member.points) points")
                                            .foregroundStyle(.blue)

                                        Text("\(member.streak) streak")
                                            .foregroundStyle(member.streak > 0 ? .orange : .secondary)

                                        if let badge = badgeText(for: member) {
                                            Text(badge)
                                        }
                                    }
                                    .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(project.name)
            } else {
                ContentUnavailableView("Project Not Found", systemImage: "exclamationmark.triangle")
            }
        }
    }

    @ViewBuilder
    private func taskRow(project: Project, member: Member, task: Task) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                toggleTaskCompletion(project: project, memberID: member.id, taskID: task.id)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(dueDateColor(for: task.dueDate))

                if task.isCompleted, let completionDate = task.completedDate {
                    Text("Completed: \(completionDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func toggleTaskCompletion(project: Project, memberID: UUID, taskID: UUID) {
        guard let memberIndex = project.members.firstIndex(where: { $0.id == memberID }) else { return }
        guard let taskIndex = project.members[memberIndex].tasksAssigned.firstIndex(where: { $0.id == taskID }) else { return }

        var updatedProject = project
        var member = updatedProject.members[memberIndex]
        var task = member.tasksAssigned[taskIndex]
        guard !task.isCompleted else { return }

        let now = Date()
        task.isCompleted = true
        task.completedDate = now

        let completedOnTime = !Calendar.current.isDate(now, inSameDayAs: task.dueDate)
            ? now < Calendar.current.startOfDay(for: task.dueDate).addingTimeInterval(86_400)
            : true

        if completedOnTime {
            member.points += 10
            member.onTimeCompletionsCount += 1

            if let previousDate = member.lastCompletedDate,
               Calendar.current.isDate(previousDate, inSameDayAs: now)
                || Calendar.current.isDate(previousDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now) {
                member.streak += 1
            } else {
                member.streak = 1
            }
        } else {
            member.points += 5
            member.streak = 0
        }

        member.completedTasksCount += 1
        member.lastCompletedDate = now

        member.tasksAssigned[taskIndex] = task
        updatedProject.members[memberIndex] = member
        store.updateProject(updatedProject)
    }

    private func dueDateColor(for date: Date) -> Color {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return .orange
        }

        if calendar.startOfDay(for: date) < calendar.startOfDay(for: Date()) {
            return .red
        }

        return .green
    }

    private func badgeText(for member: Member) -> String? {
        let completedCount = member.completedTasksCount

        if completedCount >= 20 {
            return "🥇 Gold"
        }
        if completedCount >= 10 {
            return "🥈 Silver"
        }
        if completedCount >= 5 {
            return "🥉 Bronze"
        }
        return nil
    }
}
