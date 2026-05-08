## Why

The current TodoBar is a web prototype, but the product concept is most useful as a small native macOS utility that can be built, launched, and iterated under git control. This change defines the native app scope before implementation so the port stays focused.

## What Changes

- Convert the TodoBar prototype into a native macOS app with Chinese UI copy.
- Preserve the core left-edge todobar behavior: visible handle, slide-out panel, Today, Month Plan, custom lists, task completion, deletion, section collapse, and settings.
- Store tasks and settings locally on the Mac.
- Add a git-controlled build/run workflow so future implementation can be built and launched from checked-in commands.

## Capabilities

### New Capabilities

- `macos-todobar`: A native macOS TodoBar app with Chinese UI, local persistence, and repository-controlled build/run workflow.

### Modified Capabilities

None.

## Impact

- Future implementation will add macOS app source, project/package configuration, and build/run scripts.
- No backend, sync service, account system, or browser runtime is in scope.
