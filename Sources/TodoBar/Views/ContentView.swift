import AppKit
import SwiftUI
import TodoBarCore

struct ContentView: View {
    @EnvironmentObject private var store: TodoStore

    var body: some View {
        GeometryReader { proxy in
            let settings = store.settings
            let panelWidth = min(settings.panelWidth, max(320, Double(proxy.size.width) - settings.visibleTab))
            let offset = store.board.isPanelOpen ? 0 : -(panelWidth - settings.visibleTab)

            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    panel(settings: settings, panelWidth: panelWidth)
                    handle(settings: settings, availableHeight: proxy.size.height)
                }
                .offset(x: CGFloat(offset))
                .animation(.spring(response: settings.motionMs / 1000, dampingFraction: 0.78), value: store.board.isPanelOpen)
            }
            .frame(width: CGFloat(panelWidth + settings.visibleTab), alignment: .leading)
            .frame(maxHeight: .infinity)
            .background {
                TransparentWindowConfigurator()
                    .allowsHitTesting(false)
            }
        }
    }

    private func panel(settings: TodoSettings, panelWidth: Double) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: CGFloat(settings.cornerRadius),
            topTrailingRadius: CGFloat(settings.cornerRadius),
            style: .continuous
        )

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if store.board.isSettingsOpen {
                    SettingsView()
                } else {
                    TodoPanelView()
                }
            }
            .padding(.top, 22)
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .frame(width: CGFloat(panelWidth))
        .frame(maxHeight: .infinity)
        .background(.regularMaterial, in: shape)
        .overlay(
            shape.fill(panelTint(settings))
        )
        .overlay(
            shape.stroke(.white.opacity(settings.theme == .dark ? 0.10 : 0.42), lineWidth: 1)
        )
        .clipShape(shape)
        .shadow(color: .black.opacity(settings.theme == .dark ? 0.45 : 0.18), radius: 34, x: 16, y: 0)
    }

    private func handle(settings: TodoSettings, availableHeight: CGFloat) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 18,
            topTrailingRadius: 18,
            style: .continuous
        )

        return VStack {
            Button {
                withAnimation(.spring(response: settings.motionMs / 1000, dampingFraction: 0.78)) {
                    store.togglePanel()
                }
            } label: {
                Image(systemName: "sidebar.leading")
                    .font(.system(size: 16, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: CGFloat(settings.visibleTab), height: CGFloat(settings.buttonHeight))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .background(.thinMaterial, in: shape)
            .overlay(
                shape.stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 16, x: 6, y: 0)
            .accessibilityLabel(store.board.isPanelOpen ? "收起 TodoBar" : "展开 TodoBar")

            Spacer()
        }
        .padding(.top, max(18, CGFloat(settings.verticalPosition / 100) * availableHeight))
        .frame(width: CGFloat(settings.visibleTab))
        .frame(maxHeight: .infinity)
    }

    private func panelTint(_ settings: TodoSettings) -> Color {
        let opacity = max(0.02, min(0.18, (100 - settings.surfaceOpacity) / 100))
        return settings.theme == .dark ? Color.black.opacity(opacity + 0.12) : Color.white.opacity(opacity)
    }
}

private struct TransparentWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        configure(from: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configure(from: nsView)
    }

    private func configure(from view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else {
                return
            }

            window.isOpaque = false
            window.backgroundColor = .clear
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.styleMask.insert(.fullSizeContentView)
        }
    }
}
