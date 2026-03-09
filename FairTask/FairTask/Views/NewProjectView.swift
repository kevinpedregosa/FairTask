import SwiftUI

struct NewProjectView: View {
    @Environment(ProjectManager.self) private var projectManager
    @Environment(\.dismiss) private var dismiss

    @State private var projectName = ""
    @State private var memberNames: [String] = [""]

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                }

                Section("Team Members") {
                    ForEach(memberNames.indices, id: \.self) { index in
                        HStack {
                            TextField("Member Name", text: $memberNames[index])

                            if memberNames.count > 1 {
                                Button(role: .destructive) {
                                    memberNames.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button("Add Member") {
                        memberNames.append("")
                    }
                }
            }
            .navigationTitle("New Project")
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
                    Button("Create") {
                        createProject()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        let hasName = !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAtLeastOneMember = memberNames.contains {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return hasName && hasAtLeastOneMember
    }

    private func createProject() {
        let cleanedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        let members = memberNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { TeamMember(name: $0) }

        guard !cleanedName.isEmpty, !members.isEmpty else { return }

        projectManager.addProject(Project(name: cleanedName, members: members, tasks: []))
        dismiss()
    }
}

#Preview {
    NewProjectView()
        .environment(ProjectManager())
}
