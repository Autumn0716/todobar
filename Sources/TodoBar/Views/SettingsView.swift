import SwiftUI
import TodoBarCore

struct SettingsView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            HStack(spacing: 8) {
                tabButton(L.t("settings.tab.general"), tab: .general)
                tabButton(L.t("settings.tab.ui"), tab: .ui)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if store.settings.activeTab == .general {
                        generalSettings
                    } else {
                        uiSettings
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }

    private var generalSettings: some View {
        Group {
            SettingsGroup(title: L.t("settings.appearance")) {
                HStack(spacing: 8) {
                    themeButton(L.t("settings.theme.light"), themeValue: .light)
                    themeButton(L.t("settings.theme.dark"), themeValue: .dark)
                }
            }

            SettingsGroup(title: L.t("settings.language")) {
                HStack(spacing: 8) {
                    langButton(L.t("lang.zh"), tag: "zh")
                    langButton(L.t("lang.en"), tag: "en")
                }
            }

            SettingsGroup(title: L.t("settings.basics")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(L.t("settings.doubleClickToggle"), isOn: doubleClickBinding)
                        .blackToggle()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.ink)

                    Toggle(L.t("settings.autoShowHide"), isOn: autoShowHideBinding)
                        .blackToggle()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.ink)
                }
            }

            SettingsGroup(title: L.t("settings.desktop")) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(L.t("settings.launchAtLogin"), isOn: launchAtLoginBinding)
                        .blackToggle()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.ink)

                    Toggle(L.t("settings.showDockIcon"), isOn: showDockIconBinding)
                        .blackToggle()
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.ink)
                }
            }
        }
    }

    private var uiSettings: some View {
        Group {
            SettingsGroup(title: L.t("settings.window")) {
                SliderRow(title: L.t("settings.panelWidth"), value: panelWidthBinding, range: 300...460, step: 1, suffix: "px")
                SliderRow(title: L.t("settings.visibleTab"), value: visibleTabBinding, range: 18...76, step: 1, suffix: "px")
            }

            SettingsGroup(title: L.t("settings.handle")) {
                SliderRow(title: L.t("settings.buttonHeight"), value: buttonHeightBinding, range: 52...128, step: 1, suffix: "px")
                SliderRow(title: L.t("settings.verticalPos"), value: verticalPositionBinding, range: 8...68, step: 1, suffix: "%")
            }

            SettingsGroup(title: L.t("settings.tasks")) {
                SliderRow(title: L.t("settings.rowHeight"), value: rowHeightBinding, range: 38...62, step: 1, suffix: "px")
                SliderRow(title: L.t("settings.rowGap"), value: rowGapBinding, range: 4...16, step: 1, suffix: "px")
                SliderRow(title: L.t("settings.textSize"), value: textSizeBinding, range: 11...15, step: 0.5, suffix: "px")
            }

            SettingsGroup(title: L.t("settings.feel")) {
                SliderRow(title: L.t("settings.motion"), value: motionBinding, range: 80...520, step: 10, suffix: "ms")
                SliderRow(title: L.t("settings.cornerRadius"), value: cornerRadiusBinding, range: 10...30, step: 1, suffix: "px")
                SliderRow(title: L.t("settings.surface"), value: surfaceOpacityBinding, range: 78...100, step: 1, suffix: "%")
            }
        }
    }

    private var header: some View {
        HStack {
            Text(L.t("settings.title"))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.ink)

            Spacer()

            Button {
                store.resetSettings()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 34, height: 34)
            }
            .fluidButton()
            .foregroundStyle(theme.muted)
            .accessibilityLabel(L.t("settings.reset"))

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    store.hideSettings()
                }
            } label: {
                Image(systemName: "xmark")
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .fluidButton()
            .foregroundStyle(theme.muted)
            .accessibilityLabel(L.t("settings.close"))
        }
    }

    private func tabButton(_ title: String, tab: SettingsTab) -> some View {
        let isSelected = store.settings.activeTab == tab
        return Button {
            store.updateSettings { $0.activeTab = tab }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(isSelected ? .white : theme.ink)
                .background(isSelected ? Color.black : theme.surfaceSoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func langButton(_ title: String, tag: String) -> some View {
        let isSelected = store.settings.language == tag
        let isDark = store.settings.theme == .dark
        return Button {
            store.updateSettings { $0.language = tag }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(isSelected ? (isDark ? .black : .white) : theme.muted)
                .background(isSelected ? (isDark ? Color.white : Color.black) : theme.surfaceSoft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func themeButton(_ title: String, themeValue: TodoTheme) -> some View {
        Button {
            store.updateSettings { $0.theme = themeValue }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(store.settings.theme == themeValue ? (themeValue == .dark ? .black : .white) : theme.muted)
                .background(store.settings.theme == themeValue ? (themeValue == .dark ? Color.white : Color.black) : theme.surfaceSoft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func binding(_ keyPath: WritableKeyPath<TodoSettings, Double>) -> Binding<Double> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { newValue in store.updateSettings { $0[keyPath: keyPath] = newValue } }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { store.settings.launchAtLogin },
            set: { value in store.updateSettings { $0.launchAtLogin = value } }
        )
    }

    private var showDockIconBinding: Binding<Bool> {
        Binding(
            get: { store.settings.showDockIcon },
            set: { value in store.updateSettings { $0.showDockIcon = value } }
        )
    }

    private var panelWidthBinding: Binding<Double> {
        binding(\.panelWidth)
    }

    private var visibleTabBinding: Binding<Double> {
        binding(\.visibleTab)
    }

    private var buttonHeightBinding: Binding<Double> {
        binding(\.buttonHeight)
    }

    private var verticalPositionBinding: Binding<Double> {
        binding(\.verticalPosition)
    }

    private var rowHeightBinding: Binding<Double> {
        binding(\.rowHeight)
    }

    private var rowGapBinding: Binding<Double> {
        binding(\.rowGap)
    }

    private var textSizeBinding: Binding<Double> {
        binding(\.textSize)
    }

    private var motionBinding: Binding<Double> {
        binding(\.motionMs)
    }

    private var cornerRadiusBinding: Binding<Double> {
        binding(\.cornerRadius)
    }

    private var surfaceOpacityBinding: Binding<Double> {
        binding(\.surfaceOpacity)
    }

    private var doubleClickBinding: Binding<Bool> {
        Binding(
            get: { store.settings.doubleClickToToggle },
            set: { value in store.updateSettings { $0.doubleClickToToggle = value } }
        )
    }

    private var languageBinding: Binding<String> {
        Binding(
            get: { store.settings.language },
            set: { value in store.updateSettings { $0.language = value } }
        )
    }

    private var activeTabBinding: Binding<SettingsTab> {
        Binding(
            get: { store.settings.activeTab },
            set: { value in store.updateSettings { $0.activeTab = value } }
        )
    }

    private var autoShowHideBinding: Binding<Bool> {
        Binding(
            get: { store.settings.autoShowHide },
            set: { value in store.updateSettings { $0.autoShowHide = value } }
        )
    }
}

private struct SettingsGroup<Content: View>: View {
    @Environment(\.webTheme) private var theme
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(theme.muted)
                .tracking(0.8)

            content
                .padding(12)
                .background(theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
        }
    }
}

private struct SliderRow: View {
    @Environment(\.webTheme) private var theme
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.ink)

                Spacer()

                Text(valueText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.muted)
            }

            Slider(value: $value, in: range, step: step)
                .tint(theme.ink)
        }
    }

    private var valueText: String {
        if step < 1 {
            return String(format: "%.1f%@", value, suffix)
        }

        return "\(Int(value.rounded()))\(suffix)"
    }
}
