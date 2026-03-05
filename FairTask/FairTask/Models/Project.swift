import Foundation

struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var members: [TeamMember]
    var tasks: [Task]
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        members: [TeamMember] = [],
        tasks: [Task] = [],
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.tasks = tasks
        self.createdDate = createdDate
    }

    func member(withId id: UUID) -> TeamMember? {
        members.first { $0.id == id }
    }

    func tasksForMember(_ memberId: UUID) -> [Task] {
        tasks.filter { $0.assignedToId == memberId }
    }

    mutating func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    mutating func updateMember(_ member: TeamMember) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members[index] = member
        }
    }
}
