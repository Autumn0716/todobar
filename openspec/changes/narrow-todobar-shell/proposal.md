## Why

The current native TodoBar still includes a decorative desktop backdrop. The requested direction is a cleaner utility: keep only the narrow TodoBar itself and add a simple black-and-white app icon that matches the product.

## Goals

- Remove the visible background/backdrop from the native macOS app window.
- Keep the TodoBar panel and handle as the only visible UI surface.
- Add a black-and-white app icon to the staged macOS bundle.
- Preserve existing task, settings, persistence, build, and run behavior.

## Non-Goals

- Redesign task interactions or settings behavior.
- Add App Store packaging or notarization.
- Change the web prototype.

## Success Criteria

- The launched app no longer shows the decorative background scene.
- The panel and handle remain usable.
- `dist/TodoBar.app` includes a theme-appropriate black-and-white icon.
- Existing tests and the build/run verification continue to pass.
