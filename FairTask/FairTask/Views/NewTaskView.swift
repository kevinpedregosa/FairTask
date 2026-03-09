import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let project: Project

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)

                Text("New Task Form Coming Next")
                    .font(.headline)

                Text("Project: \(project.name)")
                    .foregroundStyle(.secondary)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("New Task")
        }
    }
}

#Preview {
    let member = TeamMember(name: "Alice Johnson")
    let project = Project(name: "Test Project", members: [member], tasks: [])
    return NewTaskView(project: project)
}
