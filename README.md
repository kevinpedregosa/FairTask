# FairTask

SwiftUI app (Swift 5) for single-user project management with task gamification.

## Included Source

- `/Users/kevinpedregosa/Documents/FairTask/FairTask/FairTaskApp.swift`
- `/Users/kevinpedregosa/Documents/FairTask/FairTask/Models`
- `/Users/kevinpedregosa/Documents/FairTask/FairTask/ViewModels`
- `/Users/kevinpedregosa/Documents/FairTask/FairTask/Views`
- `/Users/kevinpedregosa/Documents/FairTask/FairTask/Storage`
- `/Users/kevinpedregosa/Documents/FairTask/FairTask/Utilities`

## Features Implemented

- Home screen with `Create New Project` and saved project list.
- Create Project flow with:
  - project name input
  - member add/list
  - task add (name, due date, manual assignment)
  - optional auto fair split of current tasks
  - save and navigate to dashboard
- Dashboard with:
  - member points/streak
  - expandable assigned tasks
  - completion checkbox
  - due-date status colors (overdue red, today orange, future green)
  - badge milestones (Bronze/Silver/Gold)
- Local storage in `UserDefaults` per project ID using JSON encoding.
