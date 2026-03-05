import Foundation

struct TeamMember: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String

    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var completedTasksCount: Int
    var onTimeCompletionsCount: Int

    var tasksAssigned: [Task]
    var lastCompletedDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        totalPoints: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        completedTasksCount: Int = 0,
        onTimeCompletionsCount: Int = 0,
        tasksAssigned: [Task] = [],
        lastCompletedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.completedTasksCount = completedTasksCount
        self.onTimeCompletionsCount = onTimeCompletionsCount
        self.tasksAssigned = tasksAssigned
        self.lastCompletedDate = lastCompletedDate
    }

    var badge: String? {
        if onTimeCompletionsCount >= 10 {
            return "🏆"
        } else if onTimeCompletionsCount >= 5 {
            return "⭐"
        } else if currentStreak >= 3 {
            return "🔥"
        }
        return nil
    }

    // Compatibility aliases so existing views/services can keep using previous names.
    var points: Int {
        get { totalPoints }
        set { totalPoints = newValue }
    }

    var streak: Int {
        get { currentStreak }
        set {
            currentStreak = newValue
            longestStreak = max(longestStreak, newValue)
        }
    }
}

typealias Member = TeamMember
