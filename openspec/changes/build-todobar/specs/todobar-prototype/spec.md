## ADDED Requirements

### Requirement: Left-edge todobar shell
The system SHALL render a left-edge todobar with a visible handle, a rounded sliding panel, and light/dark appearance options.

#### Scenario: Panel opens and closes from the left handle
- **WHEN** the user clicks the visible handle
- **THEN** the todobar panel toggles between collapsed and expanded states

#### Scenario: Theme changes
- **WHEN** the user chooses Light or Dark in settings
- **THEN** the todobar shell updates its colors without reloading the page

### Requirement: Task sections
The system SHALL provide Today, Month Plan, and custom Lists sections with task rows matching the reference structure.

#### Scenario: Seed tasks are visible
- **WHEN** the app first loads
- **THEN** it displays sample tasks in Today, Month Plan, and a General custom list

#### Scenario: Section can collapse
- **WHEN** the user clicks a section collapse control
- **THEN** that section hides or shows its task list while preserving the section header

### Requirement: Task actions
The system SHALL allow users to add, complete, and delete tasks within the visible sections.

#### Scenario: Add task
- **WHEN** the user enters text in an add row and submits it
- **THEN** a new incomplete task appears in that section

#### Scenario: Complete task
- **WHEN** the user toggles a task completion control
- **THEN** the task row updates to completed styling and section counts update

#### Scenario: Delete task
- **WHEN** the user clicks a task delete control
- **THEN** the task is removed from that section

### Requirement: Custom lists
The system SHALL allow users to create custom lists from the Lists section.

#### Scenario: Add custom list
- **WHEN** the user enters a new list name and submits it
- **THEN** a new custom list section appears with an empty task input

### Requirement: Live settings controls
The system SHALL expose settings controls for theme, panel width, handle width, button height, vertical position, row height, row gap, text size, motion duration, corner radius, and surface opacity.

#### Scenario: Settings update layout live
- **WHEN** the user moves a settings slider
- **THEN** the relevant todobar dimension or motion value updates immediately

### Requirement: Local persistence
The system SHALL persist tasks, custom lists, completed state, collapsed state, and settings in browser local storage.

#### Scenario: Refresh preserves state
- **WHEN** the user changes tasks or settings and refreshes the page
- **THEN** the app restores those changes from local storage
