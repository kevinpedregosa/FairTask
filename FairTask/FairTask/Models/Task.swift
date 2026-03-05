import Foundation

enum TaskStatus {
    case completed
    case overdue
    case dueToday
    case upcoming
}

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var assignedToId: UUID
    var isCompleted: Bool
    var completedDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        dueDate: Date,
        assignedToId: UUID,
        isCompleted: Bool = false,
        completedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.assignedToId = assignedToId
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }

    var status: TaskStatus {
        let calendar = Calendar.current
        if isCompleted {
            return .completed
        } else if calendar.isDateInToday(dueDate) {
            return .dueToday
        } else if dueDate < Date() {
            return .overdue
        } else {
            return .upcoming
        }
    }

    var wasCompletedOnTime: Bool {
        guard let completedDate else { return false }
        return completedDate <= dueDate
    }

    var pointsAwarded: Int {
        if !isCompleted { return 0 }
        return wasCompletedOnTime ? 10 : 5
    }
}
