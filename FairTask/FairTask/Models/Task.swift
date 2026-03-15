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
    var pointsWorth: Int

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        dueDate: Date,
        assignedToId: UUID,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        pointsWorth: Int = 10
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.assignedToId = assignedToId
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.pointsWorth = pointsWorth
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
        return wasCompletedOnTime ? pointsWorth : max(1, pointsWorth / 2)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case dueDate
        case assignedToId
        case isCompleted
        case completedDate
        case pointsWorth
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        assignedToId = try container.decode(UUID.self, forKey: .assignedToId)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        completedDate = try container.decodeIfPresent(Date.self, forKey: .completedDate)
        pointsWorth = try container.decodeIfPresent(Int.self, forKey: .pointsWorth) ?? 10
    }
}
