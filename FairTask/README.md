# FairTask

FairTask is a SwiftUI project and task manager focused on small teams. It lets you create projects, add team members, assign tasks with due dates, and track progress with streaks and trophy points.

## What
FairTask organizes work into projects that contain members and tasks. Each task has an assignee, a due date, and a trophy value. The project detail view provides a team overview and a task list so you can see who is responsible for what and how work is progressing.

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
3. Add tasks with a due date, assignee, and trophy value.
4. Mark tasks complete from the task list.
5. Review the team overview to see streaks and trophy totals.

## Features
- Project list with create and delete actions.
- Team overview with streaks and trophy totals.
- Tasks with due dates, status coloring, and trophy values.
- Local persistence via `UserDefaults`.

## Contributing
### Project Structure
- `FairTask/Models` contains `Project`, `Task`, and `TeamMember`.
- `FairTask/Views` contains SwiftUI views for the dashboard, project detail, and forms.
- `FairTask/Services` handles local storage and project persistence.
- `FairTask/ProjectManager.swift` coordinates app state and updates.

### Development Notes
- State is managed with an `@Observable` `ProjectManager`.
- Data is stored locally as JSON in `UserDefaults` under the key `FairTaskProjects`.
- There are no required external dependencies.

### Tests
Unit and UI test targets exist in `FairTaskTests` and `FairTaskUITests`. You can run them from Xcode's Test navigator.
