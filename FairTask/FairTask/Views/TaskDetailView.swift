import SwiftUI

struct TaskDetailView: View {
    @Environment(ProjectManager.self) private var projectManager
    let task: Task
    let project: Project
    @State private var showingEdit = false
    @State private var draftTitle = ""
    @State private var draftDescription = ""
    @State private var draftDueDate = Date()
    @State private var draftAssignedToId: UUID = UUID()
    @State private var draftPointsWorth = 10

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentTask.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(statusColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    Text(currentTask.description.isEmpty ? "No description provided." : currentTask.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Assignment Details")
                        .font(.headline)

                    detailRow(label: "Assigned to", value: assignedMemberName)
                    detailRow(label: "Due date", value: formattedDueDate)
                    detailRow(label: "Status", value: statusText)
                    if let completedDateText {
                        detailRow(label: "Completed on", value: completedDateText)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Rewards")
                        .font(.headline)

                    detailRow(label: "Points worth", value: "\(currentTask.pointsWorth)")
                    if currentTask.isCompleted {
                        detailRow(label: "Points awarded", value: "\(currentTask.pointsAwarded)")
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    draftTitle = currentTask.title
                    draftDescription = currentTask.description
                    draftDueDate = currentTask.dueDate
                    draftAssignedToId = currentTask.assignedToId
                    draftPointsWorth = currentTask.pointsWorth
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                Form {
                    Section("Task") {
                        TextField("Title", text: $draftTitle)
                        TextField("Description", text: $draftDescription, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section("Assignment") {
                        DatePicker("Due date", selection: $draftDueDate, displayedComponents: .date)

                        Picker("Assigned to", selection: $draftAssignedToId) {
                            ForEach(currentProject.members) { member in
                                Text(member.name).tag(member.id)
                            }
                        }
                    }

                    Section("Rewards") {
                        Stepper("Points: \(draftPointsWorth)", value: $draftPointsWorth, in: 1...50)
                    }
                }
                .navigationTitle("Edit Task")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingEdit = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            projectManager.updateTaskDetails(
                                currentTask,
                                in: currentProject,
                                title: draftTitle,
                                description: draftDescription,
                                dueDate: draftDueDate,
                                pointsWorth: draftPointsWorth,
                                assignedToId: draftAssignedToId
                            )
                            showingEdit = false
                        }
                        .disabled(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private var currentProject: Project {
        projectManager.projects.first { $0.id == project.id } ?? project
    }

    private var currentTask: Task {
        currentProject.tasks.first { $0.id == task.id } ?? task
    }

    private var assignedMemberName: String {
        currentProject.member(withId: currentTask.assignedToId)?.name ?? "Unassigned"
    }

    private var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: currentTask.dueDate)
    }

    private var completedDateText: String? {
        guard let completedDate = currentTask.completedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: completedDate)
    }

    private var statusText: String {
        switch currentTask.status {
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
        switch currentTask.status {
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

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let member = TeamMember(name: "Alice Johnson")
    let task = Task(
        title: "Research Abstract",
        description: "Gather sources and outline the abstract for the research report.",
        dueDate: Date().addingTimeInterval(86_400 * 2),
        assignedToId: member.id,
        isCompleted: false,
        pointsWorth: 10
    )
    let project = Project(name: "Test Project", members: [member], tasks: [task])

    return NavigationStack {
        TaskDetailView(task: task, project: project)
    }
    .environment({
        let manager = ProjectManager()
        manager.projects = [project]
        return manager
    }())
}
