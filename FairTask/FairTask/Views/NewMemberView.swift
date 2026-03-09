import SwiftUI

struct NewMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectManager.self) private var projectManager

    let project: Project

    @State private var memberName = ""

    var body: some View {
        Form {
            Section("Member Details") {
                TextField("Member Name", text: $memberName)
            }
        }
        .navigationTitle("New Member")
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
                    createMember()
                }
                .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        !memberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createMember() {
        projectManager.addMember(named: memberName, to: project)
        dismiss()
    }
}

#Preview {
    let project = Project(name: "Mobile App Redesign", members: [TeamMember(name: "Alice Johnson")])
    return NavigationStack {
        NewMemberView(project: project)
    }
    .environment(ProjectManager())
}
