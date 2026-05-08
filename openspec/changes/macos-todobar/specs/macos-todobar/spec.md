## ADDED Requirements

### Requirement: Native macOS application
The system SHALL provide a native macOS TodoBar application that can be launched outside the browser.

#### Scenario: App launches as a macOS app
- **WHEN** the user runs the repository's app launch workflow
- **THEN** the TodoBar opens as a macOS application rather than a web page

### Requirement: Chinese user interface
The system SHALL present primary user-facing TodoBar labels, controls, settings, and empty states in Chinese.

#### Scenario: Main TodoBar copy is Chinese
- **WHEN** the user opens the TodoBar task view
- **THEN** section names, action labels, placeholders, and settings entry points are displayed in Chinese

#### Scenario: Settings copy is Chinese
- **WHEN** the user opens settings
- **THEN** setting names and control labels are displayed in Chinese

### Requirement: Left-edge TodoBar panel
The system SHALL provide a compact left-edge handle that toggles a slide-out TodoBar panel.

#### Scenario: Panel toggles from the handle
- **WHEN** the user activates the visible left-edge handle
- **THEN** the TodoBar panel opens or closes while keeping the handle available

### Requirement: Task sections and custom lists
The system SHALL provide Today, Month Plan, and custom list sections with task rows and section collapse behavior.

#### Scenario: Default sections are available
- **WHEN** the user opens the app for the first time
- **THEN** the TodoBar displays Chinese equivalents of Today, Month Plan, and at least one custom list area

#### Scenario: Section can collapse
- **WHEN** the user toggles a section collapse control
- **THEN** that section hides or shows its task rows while preserving the section header

### Requirement: Task management
The system SHALL allow users to add, complete, and delete tasks within available sections.

#### Scenario: Add task
- **WHEN** the user enters a non-empty task title in a section add control
- **THEN** a new incomplete task appears in that section

#### Scenario: Complete task
- **WHEN** the user toggles a task completion control
- **THEN** the task updates between incomplete and completed states

#### Scenario: Delete task
- **WHEN** the user activates a task delete control
- **THEN** the task is removed from its section

### Requirement: Settings controls
The system SHALL provide settings for appearance and panel layout comparable to the prototype.

#### Scenario: Settings update app appearance
- **WHEN** the user changes a supported appearance or layout setting
- **THEN** the TodoBar updates the relevant visual behavior without requiring a rebuild

### Requirement: Local persistence
The system SHALL persist tasks, custom lists, completed state, collapsed state, panel state, and settings locally between app launches.

#### Scenario: Relaunch restores state
- **WHEN** the user changes tasks or settings and relaunches the app
- **THEN** the app restores the saved local state

### Requirement: Git-controlled build and run workflow
The system SHALL include repository-controlled commands for building and running the macOS app.

#### Scenario: Build command succeeds
- **WHEN** the user runs the documented build command from the repository
- **THEN** the macOS app build completes or reports actionable compiler errors

#### Scenario: Run command launches app
- **WHEN** the user runs the documented launch command from the repository after a successful build
- **THEN** the native TodoBar app launches
