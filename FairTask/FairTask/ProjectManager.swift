import Foundation
import Observation
import SwiftUI

@Observable
class ProjectManager {
    var projects: [Project] = []
    private let storageService = StorageService()

    init() {
        loadProjects()
        if projects.isEmpty {
            loadSampleData()
        }
    }

    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }

    func deleteProjects(at indexSet: IndexSet) {
        projects.remove(atOffsets: indexSet)
        saveProjects()
    }

    func completeTask(_ task: Task, in project: Project) {
        var updatedTask = task
        updatedTask.isCompleted = true
        updatedTask.completedDate = Date()

        var updatedProject = project
        updatedProject.updateTask(updatedTask)

        if var member = updatedProject.member(withId: task.assignedToId) {
            member.totalPoints += updatedTask.pointsAwarded
            member.completedTasksCount += 1

            if updatedTask.wasCompletedOnTime {
                member.currentStreak += 1
                member.longestStreak = max(member.longestStreak, member.currentStreak)
                member.onTimeCompletionsCount += 1
            } else {
                member.currentStreak = 0
            }

            member.lastCompletedDate = updatedTask.completedDate

            if let taskIndex = member.tasksAssigned.firstIndex(where: { $0.id == updatedTask.id }) {
                member.tasksAssigned[taskIndex] = updatedTask
            }

            updatedProject.updateMember(member)
        }

        updateProject(updatedProject)
    }

    private func saveProjects() {
        storageService.save(projects)
    }

    private func loadProjects() {
        projects = storageService.load()
    }

    private func loadSampleData() {
        let now = Date()
        let calendar = Calendar.current

        let aliceId = UUID()
        let bobId = UUID()
        let carolId = UUID()

        let task1 = Task(
            title: "Design mockups",
            description: "Create updated home and dashboard wireframes.",
            dueDate: calendar.date(byAdding: .day, value: 2, to: now) ?? now,
            assignedToId: aliceId
        )

        let task2 = Task(
            title: "Set up database",
            description: "Configure local storage schema and migration plan.",
            dueDate: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            assignedToId: bobId
        )

        let task3 = Task(
            title: "Write documentation",
            description: "Document architecture and onboarding notes.",
            dueDate: now,
            assignedToId: carolId
        )

        let task4 = Task(
            title: "Code review",
            description: "Review project creation and dashboard flows.",
            dueDate: calendar.date(byAdding: .day, value: 5, to: now) ?? now,
            assignedToId: aliceId,
            isCompleted: true,
            completedDate: now
        )

        let member1 = TeamMember(
            id: aliceId,
            name: "Alice Johnson",
            totalPoints: 30,
            currentStreak: 3,
            longestStreak: 4,
            completedTasksCount: 3,
            onTimeCompletionsCount: 3,
            tasksAssigned: [task1, task4],
            lastCompletedDate: now
        )

        let member2 = TeamMember(
            id: bobId,
            name: "Bob Smith",
            totalPoints: 15,
            currentStreak: 0,
            longestStreak: 2,
            completedTasksCount: 2,
            onTimeCompletionsCount: 1,
            tasksAssigned: [task2],
            lastCompletedDate: calendar.date(byAdding: .day, value: -2, to: now)
        )

        let member3 = TeamMember(
            id: carolId,
            name: "Carol Davis",
            totalPoints: 20,
            currentStreak: 2,
            longestStreak: 3,
            completedTasksCount: 2,
            onTimeCompletionsCount: 2,
            tasksAssigned: [task3],
            lastCompletedDate: calendar.date(byAdding: .day, value: -1, to: now)
        )

        let project = Project(
            name: "Mobile App Redesign",
            members: [member1, member2, member3],
            tasks: [task1, task2, task3, task4]
        )

        addProject(project)
    }
}
