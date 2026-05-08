## Context

The repository is an empty git project with OpenSpec and GitNexus metadata. The reference is a 29.952 second X video by Leon Lin showing a left-edge sidebar todo panel named "Todobar." The visible UI includes a rounded white panel, a small left tab handle, grouped task sections, inline add rows, completed task styling, delete controls, and a settings screen with sliders for sizing and motion.

Assumption: this change should create a browser prototype that captures the product feel and interactions. It will not attempt to reproduce or embed the original video, clone private implementation details, or build a native desktop app.

## Goals / Non-Goals

**Goals:**
- Provide a runnable local frontend app that looks and behaves like the referenced todobar.
- Keep implementation small enough for a prototype while preserving polished interaction details.
- Persist tasks and settings in `localStorage` so the demo survives refreshes.
- Support desktop and narrow viewport layouts without text overlap.

**Non-Goals:**
- Native OS sidebar integration, global shortcuts, launch-at-login behavior, or window management.
- Authentication, backend storage, sync, notifications, or collaboration.
- Pixel-perfect reproduction of the original demo.

## Decisions

1. Use Vite + React + TypeScript.
   - Rationale: the repository is empty, and this stack gives a fast local prototype with minimal project ceremony.
   - Alternative considered: plain HTML/CSS/JS. Simpler at first, but stateful sections, settings, persistence, and tests are easier to keep tidy with React.

2. Use local component state plus one `useLocalStorage` helper.
   - Rationale: the data model is small and local-only.
   - Alternative considered: adding a state library. That would be speculative for a single-screen prototype.

3. Model tasks as section-owned items.
   - Rationale: the reference UI is organized by Today, Month Plan, and custom lists, and per-section add/collapse behavior is central to the experience.
   - Alternative considered: a global task array with filters. That is more flexible but unnecessary for this prototype.

4. Make settings CSS-variable driven.
   - Rationale: panel width, handle size, row height, gap, text size, motion, radius, and opacity can update live without branching component logic.
   - Alternative considered: separate classes for each preset. That would not match the video where sliders adjust continuously.

## Risks / Trade-offs

- Prototype differs from native desktop behavior -> Make the left handle and slide interaction visually faithful, but document that OS-level behavior is out of scope.
- Local storage can contain malformed data -> Fall back to defaults if parsing fails.
- Too many controls can crowd mobile screens -> Use responsive constraints and allow the settings panel to scroll.
