## Why

The referenced X demo shows a compact left-edge todobar that feels useful as an always-nearby desktop productivity surface. This empty repository needs a runnable prototype that captures the core look and interactions without overbuilding a full native app.

## What Changes

- Add a browser-based todobar prototype with a left-side slide-out panel and visible handle.
- Include task sections for Today, Month Plan, and custom Lists, matching the structure shown in the reference video.
- Support basic task interactions: add tasks, mark complete, delete, collapse sections, and add a custom list.
- Add a settings view with light/dark theme controls and sliders for panel width, handle size, vertical position, task row sizing, motion, corner radius, and surface opacity.
- Persist todo data and settings locally in the browser.

## Capabilities

### New Capabilities
- `todobar-prototype`: A runnable frontend prototype for a configurable left-edge sidebar todo panel.

### Modified Capabilities

None.

## Impact

- Creates a small frontend app in the empty repository.
- Adds package metadata, source files, styling, and a local development workflow.
- Uses browser local storage only; no backend, accounts, native desktop APIs, or external services.
