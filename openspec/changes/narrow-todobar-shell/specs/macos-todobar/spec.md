## MODIFIED Requirements

### Requirement: Left-edge TodoBar panel
The system SHALL provide a compact left-edge handle that toggles a slide-out TodoBar panel, with the native macOS app visually showing only the TodoBar panel/handle surface and no decorative backdrop.

#### Scenario: Panel toggles from the handle
- **WHEN** the user activates the visible left-edge handle
- **THEN** the TodoBar panel opens or closes while keeping the handle available

#### Scenario: Window shows only TodoBar surface
- **WHEN** the user launches the native TodoBar app
- **THEN** the visible app content is limited to the TodoBar panel and handle rather than a full decorative background

### Requirement: Git-controlled build and run workflow
The system SHALL include repository-controlled commands for building and running the macOS app, including staging the app bundle icon.

#### Scenario: Build command succeeds
- **WHEN** the user runs the documented build command from the repository
- **THEN** the macOS app build completes or reports actionable compiler errors

#### Scenario: Run command launches app
- **WHEN** the user runs the documented launch command from the repository after a successful build
- **THEN** the native TodoBar app launches

#### Scenario: App bundle includes icon
- **WHEN** the repository launch workflow stages `dist/TodoBar.app`
- **THEN** the app bundle includes a black-and-white TodoBar icon referenced by its `Info.plist`
