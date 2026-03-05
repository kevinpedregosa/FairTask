import Foundation

class StorageService {
    private let key = "FairTaskProjects"
    private let userDefaults = UserDefaults.standard

    func save(_ projects: [Project]) {
        do {
            let data = try JSONEncoder().encode(projects)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to save projects: \(error.localizedDescription)")
        }
    }

    func load() -> [Project] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }

        do {
            let projects = try JSONDecoder().decode([Project].self, from: data)
            return projects
        } catch {
            print("Failed to load projects: \(error.localizedDescription)")
            return []
        }
    }
}
