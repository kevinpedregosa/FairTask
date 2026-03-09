import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectManager.self) private var projectManager
    let project: Project

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date().addingTimeInterval(86_400)
    @State private var selectedMember: TeamMember?

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Assignment") {
                    Picker("Assign to", selection: $selectedMember) {
                        Text("Select Member").tag(nil as TeamMember?)

                        ForEach(project.members) { member in
                            Text(member.name).tag(member as TeamMember?)
                        }
                    }

                    DatePicker(
                        "Due Date",
                        selection: $dueDate,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("New Task")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        createTask()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                selectedMember = project.members.first
            }
        }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMember != nil
    }

    private func createTask() {
        guard let member = selectedMember else { return }

        projectManager.addTask(
            title: title,
            description: description,
            dueDate: dueDate,
            assignedTo: member.id,
            in: project
        )

        dismiss()
    }
}

#Preview {
    let member1 = TeamMember(name: "Alice Johnson")
    let member2 = TeamMember(name: "Bob Smith")
    let project = Project(name: "Test Project", members: [member1, member2])

    return NewTaskView(project: project)
        .environment(ProjectManager())
}
