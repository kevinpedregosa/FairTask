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
        guard !task.isCompleted else { return }
        toggleTaskCompletion(task, in: project)
    }

    func toggleTaskCompletion(_ task: Task, in project: Project) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }) else { return }

        var updatedProject = projects[projectIndex]
        guard let taskIndex = updatedProject.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        var updatedTask = updatedProject.tasks[taskIndex]
        if updatedTask.isCompleted {
            updatedTask.isCompleted = false
            updatedTask.completedDate = nil
        } else {
            updatedTask.isCompleted = true
            updatedTask.completedDate = Date()
        }
        updatedProject.tasks[taskIndex] = updatedTask

        if let memberIndex = updatedProject.members.firstIndex(where: { $0.id == updatedTask.assignedToId }) {
            var member = updatedProject.members[memberIndex]
            let memberTasks = updatedProject.tasks.filter { $0.assignedToId == member.id }
            let completedTasks = memberTasks
                .filter { $0.isCompleted }
                .sorted { ($0.completedDate ?? .distantPast) < ($1.completedDate ?? .distantPast) }

            member.tasksAssigned = memberTasks
            member.totalPoints = memberTasks.reduce(0) { $0 + $1.pointsAwarded }
            member.completedTasksCount = completedTasks.count
            member.onTimeCompletionsCount = completedTasks.filter { $0.wasCompletedOnTime }.count

            var runningStreak = 0
            var longestStreak = 0
            for completedTask in completedTasks {
                if completedTask.wasCompletedOnTime {
                    runningStreak += 1
                    longestStreak = max(longestStreak, runningStreak)
                } else {
                    runningStreak = 0
                }
            }
            member.currentStreak = runningStreak
            member.longestStreak = longestStreak
            member.lastCompletedDate = completedTasks.last?.completedDate

            updatedProject.members[memberIndex] = member
        }

        updateProject(updatedProject)
    }

    func addTask(
        title: String,
        description: String,
        dueDate: Date,
        assignedTo memberId: UUID,
        in project: Project
    ) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else { return }

        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }) else { return }

        var updatedProject = projects[projectIndex]
        guard let memberIndex = updatedProject.members.firstIndex(where: { $0.id == memberId }) else { return }

        let task = Task(
            title: cleanedTitle,
            description: cleanedDescription,
            dueDate: dueDate,
            assignedToId: memberId
        )

        updatedProject.tasks.append(task)
        updatedProject.members[memberIndex].tasksAssigned.append(task)

        updateProject(updatedProject)
    }

    func addMember(named name: String, to project: Project) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        guard let projectIndex = projects.firstIndex(where: { $0.id == project.id }) else { return }

        var updatedProject = projects[projectIndex]
        updatedProject.members.append(TeamMember(name: cleanedName))
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
            assignedToId: aliceId
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
