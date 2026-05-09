import AppKit
import SwiftUI
import TodoBarCore

struct WebTheme {
    let isDark: Bool
    
    var surface: Color { isDark ? Color(red: 22/255, green: 23/255, blue: 26/255) : Color(red: 255/255, green: 255/255, blue: 255/255) }
    var surfaceSoft: Color { isDark ? Color(red: 32/255, green: 33/255, blue: 38/255) : Color(red: 246/255, green: 246/255, blue: 246/255) }
    var surfaceRaised: Color { isDark ? Color(red: 24/255, green: 25/255, blue: 29/255) : Color.white }
    var ink: Color { isDark ? Color(red: 244/255, green: 245/255, blue: 246/255) : Color(red: 16/255, green: 17/255, blue: 22/255) }
    var muted: Color { isDark ? Color(red: 164/255, green: 168/255, blue: 176/255) : Color(red: 119/255, green: 123/255, blue: 132/255) }
    var line: Color { isDark ? Color(red: 51/255, green: 54/255, blue: 61/255) : Color(red: 222/255, green: 223/255, blue: 226/255) }
    var lineStrong: Color { isDark ? Color(red: 74/255, green: 77/255, blue: 85/255) : Color(red: 201/255, green: 203/209, blue: 209/255) }
    var accent: Color { isDark ? .white : Color(red: 17/255, green: 19/255, blue: 24/255) }
}

extension EnvironmentValues {
    var webTheme: WebTheme {
        get { self[WebThemeKey.self] }
        set { self[WebThemeKey.self] = newValue }
    }
}

private struct WebThemeKey: EnvironmentKey {
    static let defaultValue = WebTheme(isDark: false)
}

struct ContentView: View {
    @EnvironmentObject private var store: TodoStore

    var body: some View {
        let _ = L.language = store.settings.language
        return GeometryReader { proxy in
            let settings = store.settings
            let theme = WebTheme(isDark: settings.theme == .dark)
            let panelWidth = settings.panelWidth

            ZStack(alignment: .leading) {
                panel(settings: settings, panelWidth: panelWidth, theme: theme)
            }
            .offset(x: store.board.isPanelOpen ? 0 : CGFloat(panelWidth))
            .blur(radius: store.board.isPanelOpen ? 0 : 20)
            .opacity(store.board.isPanelOpen ? 1 : 0)
            .onHover { hovering in
                store.isMouseInProximity = hovering
            }
            .animation(.spring(response: settings.motionMs / 1000, dampingFraction: 0.78), value: store.board.isPanelOpen)
            .frame(width: CGFloat(panelWidth), alignment: .leading)
            .frame(maxHeight: .infinity)
            .environment(\.webTheme, theme)
            .background {
                TransparentWindowConfigurator(width: CGFloat(panelWidth), isPanelOpen: store.board.isPanelOpen, isInteracting: store.isInteracting)
                    .allowsHitTesting(false)
            }
            .background {
                FloatingHandlePanelConfigurator(
                    panelWidth: CGFloat(panelWidth),
                    buttonWidth: CGFloat(settings.visibleTab),
                    buttonHeight: CGFloat(settings.buttonHeight),
                    verticalPosition: settings.verticalPosition,
                    theme: theme
                )
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }

    private func panel(settings: TodoSettings, panelWidth: Double, theme: WebTheme) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: CGFloat(settings.cornerRadius),
            bottomLeadingRadius: CGFloat(settings.cornerRadius),
            bottomTrailingRadius: 0,
            topTrailingRadius: 0,
            style: .continuous
        )

        return ScrollView {
            ZStack(alignment: .topLeading) {
                if store.board.isSettingsOpen {
                    SettingsView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    TodoPanelView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 20)
            .padding(.horizontal, 16)
            .padding(.bottom, 26)
        }
        .scrollIndicators(.never)
        .frame(width: CGFloat(panelWidth))
        .frame(maxHeight: .infinity)
        .background(theme.surface)
        .clipShape(shape)
        .overlay(
            shape.stroke(theme.line.opacity(settings.theme == .dark ? 0.15 : 0.5), lineWidth: 1)
        )
        .shadow(
            color: store.board.isPanelOpen
                ? (settings.theme == .dark ? .black.opacity(0.15) : theme.line.opacity(0.15))
                : .clear,
            radius: settings.theme == .dark ? 10 : 10,
            x: -1,
            y: 0
        )
    }
}

private struct HandleView: View {
    @EnvironmentObject private var store: TodoStore
    let theme: WebTheme

    var body: some View {
        let settings = store.settings
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 18,
            bottomLeadingRadius: 18,
            bottomTrailingRadius: 0,
            topTrailingRadius: 0,
            style: .continuous
        )

        let isActive = store.isHandleHovered || store.isInteracting

        ZStack {
            Image(systemName: "sidebar.right")
                .font(.system(size: 16, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isActive ? theme.ink : theme.muted)
        }
        .frame(width: CGFloat(settings.visibleTab), height: CGFloat(settings.buttonHeight))
        .background(theme.surface, in: shape)
        .overlay(
            shape.stroke(theme.line.opacity(settings.theme == .dark ? 0.15 : 0.5), lineWidth: 1)
        )
        .shadow(
            color: settings.theme == .dark ? .black.opacity(0.15) : theme.line.opacity(0.15),
            radius: 6,
            x: -1,
            y: 0
        )
        .offset(x: isActive ? -4 : 0)
        .scaleEffect(store.isHandlePressed ? 0.96 : 1.0)
        .compositingGroup()
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isActive)
        .animation(.spring(response: 0.15, dampingFraction: 0.8), value: store.isHandlePressed)
        .accessibilityLabel(store.board.isPanelOpen ? L.t("handle.collapse") : L.t("handle.expand"))
    }
}

private class HandleDragOverlayView: NSView {
    var onDragStart: (() -> Void)?
    var onDragMove: (() -> Void)?
    var onDragEnd: (() -> Void)?
    var onClick: (() -> Void)?
    var onHoverChanged: ((Bool) -> Void)?

    private var isDragging = false
    private var mouseDownLocation: NSPoint = .zero
    private let dragThreshold: CGFloat = 3
    private var trackingArea: NSTrackingArea?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        bounds.contains(point) ? self : nil
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect, .enabledDuringMouseDrag],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        onHoverChanged?(true)
    }

    override func mouseExited(with event: NSEvent) {
        guard !isDragging else { return }
        onHoverChanged?(false)
    }

    override func mouseDown(with event: NSEvent) {
        isDragging = false
        mouseDownLocation = NSEvent.mouseLocation
        guard let window else { return }

        while true {
            guard let next = window.nextEvent(
                matching: [.leftMouseDragged, .leftMouseUp],
                until: .distantFuture,
                inMode: .eventTracking,
                dequeue: true
            ) else { continue }

            switch next.type {
            case .leftMouseDragged:
                let currentLocation = NSEvent.mouseLocation
                let dx = currentLocation.x - mouseDownLocation.x
                let dy = currentLocation.y - mouseDownLocation.y
                let distance = sqrt(dx * dx + dy * dy)

                if !isDragging && distance >= dragThreshold {
                    isDragging = true
                    onDragStart?()
                }
                if isDragging {
                    onDragMove?()
                }

            case .leftMouseUp:
                if isDragging {
                    onDragEnd?()
                } else {
                    onClick?()
                }
                return

            default:
                break
            }
        }
    }
}

private struct FloatingHandlePanelConfigurator: NSViewRepresentable {
    @EnvironmentObject private var store: TodoStore

    let panelWidth: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    let verticalPosition: Double
    let theme: WebTheme

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            context.coordinator.update(from: view, store: store, parent: self)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.update(from: nsView, store: store, parent: self)
        }
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.close()
    }

    @MainActor
    final class Coordinator {
        private var panel: NSPanel?
        private var hostingView: NSHostingView<AnyView>?
        private var dragOverlay: HandleDragOverlayView?
        private weak var store: TodoStore?
        private var parentParams: (panelWidth: CGFloat, buttonWidth: CGFloat, buttonHeight: CGFloat, isPanelOpen: Bool)?
        private var lastScreenFrame: NSRect?
        private var lastVisibleFrame: NSRect?
        private var lastDragPercent: CGFloat = 0
        private var dragStartMouseY: CGFloat = 0
        private var dragStartPercent: CGFloat = 0

        private func clearAllBackgrounds(in view: NSView) {
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.clear.cgColor
            view.layer?.isOpaque = false
            for subview in view.subviews {
                clearAllBackgrounds(in: subview)
            }
        }

        private func computeFrame(verticalPercent: CGFloat, panelOpen: Bool) -> NSRect? {
            guard let screenFrame = lastScreenFrame,
                  let visibleFrame = lastVisibleFrame,
                  let params = parentParams else { return nil }

            let handlePadding: CGFloat = 4
            let shadowBleed: CGFloat = 10
            let handleX = panelOpen
                ? screenFrame.maxX - params.panelWidth - params.buttonWidth - handlePadding - shadowBleed
                : screenFrame.maxX - params.buttonWidth - handlePadding - shadowBleed
            let topInset = max(18, CGFloat(verticalPercent / 100) * visibleFrame.height)
            let handleY = visibleFrame.maxY - topInset - params.buttonHeight

            return NSRect(
                x: handleX,
                y: handleY,
                width: params.buttonWidth + handlePadding + shadowBleed,
                height: params.buttonHeight
            )
        }

        func setFrameDuringDrag(verticalPercent: CGFloat) {
            lastDragPercent = verticalPercent
            guard let panel,
                  let frame = computeFrame(verticalPercent: verticalPercent, panelOpen: parentParams?.isPanelOpen ?? false) else { return }
            panel.setFrame(frame, display: false)
        }

        func commitDragPosition() {
            guard let store else { return }
            let newPercent = Double(max(0, min(100, lastDragPercent)))
            store.updateSettings { $0.verticalPosition = newPercent }
        }

        private func handleHoverChanged(_ isHovered: Bool) {
            guard let store else { return }
            if isHovered {
                NSCursor.pointingHand.push()
                store.isMouseInProximity = true
                store.isHandleHovered = true
                if store.settings.autoShowHide && !store.board.isPanelOpen {
                    store.openPanel()
                }
            } else {
                NSCursor.pop()
                store.isMouseInProximity = false
                store.isHandleHovered = false
            }
        }

        private func handleDragStart() {
            guard let store else { return }
            dragStartMouseY = NSEvent.mouseLocation.y
            dragStartPercent = CGFloat(store.settings.verticalPosition)
            lastDragPercent = dragStartPercent
            store.isInteracting = true
            store.isHandlePressed = true
        }

        private func handleDragMove() {
            let currentY = NSEvent.mouseLocation.y
            let deltaY = currentY - dragStartMouseY
            guard let visibleFrame = lastVisibleFrame else { return }
            let deltaPercent = -(deltaY / visibleFrame.height) * 100
            let newPercent = max(0, min(100, dragStartPercent + deltaPercent))
            setFrameDuringDrag(verticalPercent: newPercent)
        }

        private func handleDragEnd() {
            commitDragPosition()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.store?.isInteracting = false
                self?.store?.isHandlePressed = false
            }
        }

        private func handleClick() {
            guard let store else { return }
            withAnimation(.spring(response: store.settings.motionMs / 1000, dampingFraction: 0.78)) {
                store.togglePanel()
            }
        }

        func update(from view: NSView, store: TodoStore, parent: FloatingHandlePanelConfigurator) {
            guard let screen = view.window?.screen ?? NSScreen.main else {
                return
            }

            self.store = store

            let panel = panel ?? makePanel()
            if self.panel == nil {
                self.panel = panel
            }

            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            lastScreenFrame = screenFrame
            lastVisibleFrame = visibleFrame
            parentParams = (panelWidth: parent.panelWidth, buttonWidth: parent.buttonWidth, buttonHeight: parent.buttonHeight, isPanelOpen: store.board.isPanelOpen)

            let frame = computeFrame(verticalPercent: parent.verticalPosition, panelOpen: store.board.isPanelOpen) ?? NSRect.zero

            if store.isInteracting {
                return
            }

            if !store.isInteracting {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = store.settings.motionMs / 1000.0
                    context.timingFunction = CAMediaTimingFunction(controlPoints: 0.22, 1.0, 0.36, 1.0)
                    panel.animator().setFrame(frame, display: true)
                }
            }

            panel.orderFrontRegardless()

            if let contentView = panel.contentView {
                clearAllBackgrounds(in: contentView)
                if let superview = contentView.superview {
                    clearAllBackgrounds(in: superview)
                }
            }

            let rootView = AnyView(
                HandleView(theme: parent.theme)
                    .environmentObject(store)
                    .padding(.leading, 4 + 10)
                    .frame(width: parent.buttonWidth + 4 + 10, height: parent.buttonHeight, alignment: .leading)
                    .background(Color.clear)
            )

            if !store.isInteracting {
                if let hostingView {
                    hostingView.rootView = rootView
                } else {
                    let container = NSView(frame: .zero)
                    container.wantsLayer = true
                    container.layer?.backgroundColor = NSColor.clear.cgColor
                    container.layer?.isOpaque = false

                    let hostingView = NSHostingView(rootView: rootView)
                    hostingView.wantsLayer = true
                    hostingView.layer?.backgroundColor = CGColor.clear
                    hostingView.layer?.isOpaque = false
                    hostingView.autoresizingMask = [.width, .height]
                    container.addSubview(hostingView)

                    let overlay = HandleDragOverlayView(frame: .zero)
                    overlay.wantsLayer = true
                    overlay.layer?.backgroundColor = NSColor.clear.cgColor
                    overlay.autoresizingMask = [.width, .height]
                    overlay.onDragStart = { [weak self] in self?.handleDragStart() }
                    overlay.onDragMove = { [weak self] in self?.handleDragMove() }
                    overlay.onDragEnd = { [weak self] in self?.handleDragEnd() }
                    overlay.onClick = { [weak self] in self?.handleClick() }
                    overlay.onHoverChanged = { [weak self] isHovered in self?.handleHoverChanged(isHovered) }
                    container.addSubview(overlay)

                    panel.contentView = container
                    self.hostingView = hostingView
                    self.dragOverlay = overlay

                    DispatchQueue.main.async { [weak self] in
                        self?.dragOverlay?.updateTrackingAreas()
                        if let overlay = self?.dragOverlay {
                            let mouseInScreen = NSEvent.mouseLocation
                            let pointInView = overlay.convert(mouseInScreen, from: nil)
                            if overlay.bounds.contains(pointInView) {
                                self?.handleHoverChanged(true)
                            }
                        }
                    }
                }
            }
        }

        func close() {
            dragOverlay?.removeFromSuperview()
            dragOverlay = nil
            panel?.close()
            panel = nil
            hostingView = nil
        }

        private func makePanel() -> NSPanel {
            let panel = NSPanel(
                contentRect: .zero,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.styleMask.insert(.fullSizeContentView)
            panel.contentView?.wantsLayer = true
            panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
            panel.contentView?.layer?.isOpaque = false
            return panel
        }
    }
}

private struct TransparentWindowConfigurator: NSViewRepresentable {
    @EnvironmentObject private var store: TodoStore
    let width: CGFloat
    let isPanelOpen: Bool
    let isInteracting: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            configure(from: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(from: nsView)
        }
    }

    private func clearAllBackgrounds(in view: NSView) {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        view.layer?.isOpaque = false
        for subview in view.subviews {
            clearAllBackgrounds(in: subview)
        }
    }

    private func configure(from view: NSView) {
        guard let window = view.window else {
            return
        }

        window.isOpaque = false
        window.backgroundColor = .clear

        if let contentView = window.contentView {
            clearAllBackgrounds(in: contentView)
            if let superview = contentView.superview {
                clearAllBackgrounds(in: superview)
            }
        }
        
        window.ignoresMouseEvents = !isPanelOpen
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = false
        window.isMovableByWindowBackground = false
        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.remove(.resizable)
        window.hasShadow = false
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        if let screen = window.screen ?? NSScreen.main {
            let screenFrame = screen.frame
            let visibleFrame = screen.visibleFrame
            let frame = NSRect(
                x: screenFrame.maxX - width,
                y: visibleFrame.minY,
                width: width,
                height: visibleFrame.height
            )
            if window.frame != frame {
                window.setFrame(frame, display: true)
            }
        }
    }
}
