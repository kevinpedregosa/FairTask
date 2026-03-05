import SwiftUI

struct CreateProjectView: View {
    @EnvironmentObject private var store: ProjectStore
    @Environment(\.dismiss) private var dismiss

    @State private var projectName = ""
    @State private var memberName = ""
    @State private var members: [Member] = []

    @State private var taskName = ""
    @State private var dueDate = Date()
    @State private var selectedMemberID: UUID?

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project name", text: $projectName)
            }

            Section("Members") {
                HStack {
                    TextField("Member name", text: $memberName)
                    Button("Add", action: addMember)
                        .disabled(memberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ForEach(members) { member in
                    Text(member.name)
                }
            }

            Section("Tasks") {
                TextField("Task name", text: $taskName)
                DatePicker("Due date", selection: $dueDate, displayedComponents: .date)

                Picker("Assign to", selection: $selectedMemberID) {
                    Text("Select member").tag(Optional<UUID>.none)
                    ForEach(members) { member in
                        Text(member.name).tag(Optional(member.id))
                    }
                }

                Button("Add Task", action: addTask)
                    .disabled(!canAddTask)

                if members.allSatisfy({ $0.tasksAssigned.isEmpty }) {
                    Text("No tasks added yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(members) { member in
                        ForEach(member.tasksAssigned) { task in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                Text("Assigned to: \(member.name)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Due: \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Button("Auto Assign Fair Split", action: autoAssignFairSplit)
                    .disabled(members.count < 2 || allTasks.isEmpty)
            }

            Section {
                Button("Save Project", action: saveProject)
                    .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || members.isEmpty)
            }
        }
        .navigationTitle("Create Project")
    }

    private var canAddTask: Bool {
        !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMemberID != nil
    }

    private var allTasks: [Task] {
        members.flatMap(\.tasksAssigned)
    }

    private func addMember() {
        let cleanedName = memberName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }

        let newMember = Member(name: cleanedName)
        members.append(newMember)
        memberName = ""

        if selectedMemberID == nil {
            selectedMemberID = newMember.id
        }
    }

    private func addTask() {
        let cleanedTask = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTask.isEmpty, let memberID = selectedMemberID else { return }

        let newTask = Task(title: cleanedTask, dueDate: dueDate, assignedToId: memberID)

        guard let index = members.firstIndex(where: { $0.id == memberID }) else { return }
        members[index].tasksAssigned.append(newTask)

        taskName = ""
        dueDate = Date()
    }

    private func autoAssignFairSplit() {
        let sortedTasks = allTasks.sorted { $0.dueDate < $1.dueDate }
        guard !sortedTasks.isEmpty else { return }

        for index in members.indices {
            members[index].tasksAssigned.removeAll()
        }

        for (taskIndex, task) in sortedTasks.enumerated() {
            let memberIndex = taskIndex % members.count
            var reassignedTask = task
            reassignedTask.assignedToId = members[memberIndex].id
            members[memberIndex].tasksAssigned.append(reassignedTask)
        }
    }

    private func saveProject() {
        let cleanedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty, !members.isEmpty else { return }

        store.addProject(Project(name: cleanedName, members: members))
        dismiss()
    }
}
