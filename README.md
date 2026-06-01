# FairTask

FairTask is a SwiftUI project and task manager focused on small teams. It lets you create projects, add team members, assign tasks with due dates, set point values, and track progress with streaks and points.

## Tech Stack
- Swift 5
- SwiftUI for the app interface and navigation.
- Observation and Combine for app state and shared stores.
- Foundation models using `Codable`, `UUID`, `Date`, and `Calendar`.
- Local JSON persistence with `UserDefaults`.
- Xcode project targeting Apple platforms, including iOS Simulator and macOS build destinations.
- Swift Testing for unit tests and XCTest for UI tests.
- No required third-party dependencies.

## What
FairTask organizes work into projects that contain members and tasks. Each task has an assignee, a due date, and a points value. The project detail view provides a team overview and a task list so you can see who is responsible for what and how work is progressing.

## Why
The app is designed to make project status visible at a glance and to add lightweight motivation. Streaks and trophy points provide quick feedback without adding heavy process overhead.

## How
### Run the App
1. Open `FairTask.xcodeproj` in Xcode.
2. Select a macOS or iOS simulator target.
3. Build and run.

### Use the App
1. Create a project from the home screen.
2. Add members to the project.
3. Add tasks with a due date, assignee, and points value.
4. Tap a member or task card to see full details.
5. Edit member names or task details from the detail screens.
6. Mark tasks complete from the task list.
7. Review the team overview to see streaks and point totals.
8. Use the Change Color button on the home screen to cycle the background gradient.

## Features
- Project list with create and delete actions.
- Team overview with streaks and trophy totals.
- Tasks with due dates, status coloring, and point values.
- Task and member detail pages with edit actions for names, descriptions, assignments, and points.
- Long-press delete for projects, members, and tasks.
- Shared theme background that carries from the home screen to project detail.
- Local persistence via `UserDefaults`.

## Contributing
### Project Structure
- `FairTask/Models` contains `Project`, `Task`, and `TeamMember`.
- `FairTask/Views` contains SwiftUI views for the dashboard, project detail, and forms.
- `FairTask/Services` handles local storage and app theme state.
- `FairTask/ProjectManager.swift` coordinates app state and updates.

### Development Notes
- State is managed with an `@Observable` `ProjectManager`.
- Data is stored locally as JSON in `UserDefaults` under the key `FairTaskProjects`.
- Theme colors are stored in memory via `ThemeStore` and shared through SwiftUI environment.
- There are no required external dependencies.

### Tests
Unit and UI test targets exist in `FairTaskTests` and `FairTaskUITests`. You can run them from Xcode's Test navigator.
