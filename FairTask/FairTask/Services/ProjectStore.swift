import Foundation
import Combine

final class ProjectStore: ObservableObject {
    @Published private(set) var projects: [Project] = []

    private let storageService: StorageService

    init(storageService: StorageService = StorageService()) {
        self.storageService = storageService
        loadProjects()
    }

    func addProject(_ project: Project) {
        projects.append(project)
        projects.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        saveProjects()
    }

    func updateProject(_ project: Project) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
        saveProjects()
    }

    private func loadProjects() {
        projects = storageService.load()
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func saveProjects() {
        storageService.save(projects)
    }
}
