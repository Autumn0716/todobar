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
                BackdropView()

                HStack(spacing: 0) {
                    panel(settings: settings, panelWidth: panelWidth)
                    handle(settings: settings)
                }
                .offset(x: CGFloat(offset))
                .animation(.spring(response: settings.motionMs / 1000, dampingFraction: 0.78), value: store.board.isPanelOpen)
            }
            .background(Color(nsColor: .windowBackgroundColor))
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

    private func handle(settings: TodoSettings) -> some View {
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
        .padding(.top, CGFloat(settings.verticalPosition / 100 * 720))
        .frame(width: CGFloat(settings.visibleTab))
        .frame(maxHeight: .infinity)
    }

    private func panelTint(_ settings: TodoSettings) -> Color {
        let opacity = max(0.02, min(0.18, (100 - settings.surfaceOpacity) / 100))
        return settings.theme == .dark ? Color.black.opacity(opacity + 0.12) : Color.white.opacity(opacity)
    }
}

private struct BackdropView: View {
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    colors: [
                        .black,
                        Color(red: 0.09, green: 0.10, blue: 0.13),
                        Color(red: 0.04, green: 0.04, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                AngularGradient(
                    colors: [
                        .clear,
                        Color(red: 0.37, green: 0.39, blue: 0.52).opacity(0.16),
                        .clear,
                        Color(red: 0.20, green: 0.17, blue: 0.28).opacity(0.18),
                        .clear
                    ],
                    center: .center
                )
                .blur(radius: 34)
            }

            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .opacity(0.55)
                .overlay(alignment: .topTrailing) {
                    VStack(alignment: .trailing, spacing: 12) {
                        Capsule().fill(.white.opacity(0.07)).frame(width: 170, height: 14)
                        Capsule().fill(.white.opacity(0.07)).frame(width: 170, height: 14)
                        Capsule().fill(.white.opacity(0.07)).frame(width: 170, height: 14)
                    }
                    .padding(26)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .frame(width: 580, height: 420)
                .offset(x: 220)

            Text("专注模式")
                .font(.system(size: 78, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
                .offset(x: -210, y: -80)

            Image(systemName: "archivebox")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.82))
                .frame(width: 58, height: 58)
                .background(Color(red: 0.72, green: 0.70, blue: 0.83))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .offset(x: 260, y: 310)
        }
        .ignoresSafeArea()
    }
}
