## Context

TodoBar is now a SwiftPM-based SwiftUI macOS app staged into `dist/TodoBar.app` by `script/build_and_run.sh`. The current root view renders a decorative background behind the panel. The new visual direction removes that backdrop and makes the app feel like a compact floating utility.

## Approach

1. Replace the root background composition with a transparent window surface.
   - Use a small AppKit window configurator from SwiftUI to make the window non-opaque and clear.
   - Remove the decorative `BackdropView`.

2. Keep the existing panel and handle structure.
   - Preserve the slide-out behavior and current settings controls.
   - Size the SwiftUI content to the panel plus handle so the app opens as a narrow TodoBar surface.

3. Add a black-and-white bundle icon.
   - Generate an iconset that represents a narrow vertical TodoBar with a checkmark/list motif.
   - Convert the iconset to `AppIcon.icns` during app staging and reference it from `Info.plist`.

## Risks

- Transparent macOS windows can expose a rectangular click area even when no pixels are drawn. This is acceptable for this pass because the user asked for visual cleanup, not advanced hit-test shaping.
- SwiftPM GUI app staging is manual, so icon wiring belongs in the build script until a full Xcode project/package resource flow is introduced.
