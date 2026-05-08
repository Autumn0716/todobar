## Context

The repository currently contains a Vite/React TodoBar prototype with a left-edge sliding panel, task sections, custom lists, settings sliders, and browser local storage. The native version should keep the product shape but become a macOS app with Chinese-facing labels and a repeatable build/run workflow stored in git.

Assumption: the implementation should prioritize a straightforward SwiftUI macOS app over wrapping the web prototype, because the requested outcome is native macOS behavior rather than a browser shell.

## Goals / Non-Goals

**Goals:**

- Build a native macOS TodoBar app with Chinese UI text.
- Preserve the prototype's main task and settings interactions.
- Persist local task data and settings between launches.
- Provide checked-in commands or scripts for build and run so the workflow is reproducible from git.

**Non-Goals:**

- Cloud sync, accounts, collaboration, notifications, or calendar integration.
- App Store packaging, notarization, auto-update, or installer generation.
- Pixel-perfect parity with the web CSS implementation.

## Decisions

1. Use SwiftUI for the app UI.
   - Rationale: SwiftUI is the simplest native path for a compact macOS utility with forms, lists, buttons, and settings.
   - Alternative considered: WKWebView wrapper around the existing prototype. That would reuse UI code but would not satisfy the native-app direction as cleanly.

2. Use a local value model for sections, tasks, and settings.
   - Rationale: the current prototype data is small and document-like, so a lightweight Codable model is enough.
   - Alternative considered: Core Data or SwiftData. Those add migration and model ceremony that is not needed for this scope.

3. Store app state locally using a Codable file or UserDefaults-backed storage.
   - Rationale: both support local persistence without external services; the implementation can choose the smaller fit while preserving the required behavior.
   - Alternative considered: database storage. That is unnecessary for a single-user task panel.

4. Keep build/run workflow in git-controlled files.
   - Rationale: future agents and users should be able to build and launch the app with documented repository commands.
   - Alternative considered: relying only on Xcode UI actions. That is harder to reproduce and review.

## Risks / Trade-offs

- Native window behavior may differ from the browser prototype -> Keep the visible handle and slide-out panel as the required user-facing behavior, while allowing implementation-specific macOS window mechanics.
- Chinese copy may need later terminology refinement -> Centralize visible strings so wording can be adjusted without changing behavior.
- Minimal persistence may limit future sync features -> Keep storage local and simple for this change; future sync can be proposed separately.
