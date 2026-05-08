import SwiftUI
import TodoBarCore

struct SettingsView: View {
    @EnvironmentObject private var store: TodoStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            SettingsGroup(title: "外观") {
                HStack(spacing: 8) {
                    themeButton("浅色", theme: .light)
                    themeButton("深色", theme: .dark)
                }
            }

            SettingsGroup(title: "桌面") {
                Toggle("登录时启动", isOn: launchAtLoginBinding)
                    .toggleStyle(.switch)
                    .font(.system(size: 14, weight: .bold))
            }

            SettingsGroup(title: "窗口") {
                SliderRow(title: "面板宽度", value: panelWidthBinding, range: 300...460, step: 1, suffix: "px")
                SliderRow(title: "可见标签", value: visibleTabBinding, range: 18...76, step: 1, suffix: "px")
            }

            SettingsGroup(title: "把手") {
                SliderRow(title: "按钮高度", value: buttonHeightBinding, range: 52...128, step: 1, suffix: "px")
                SliderRow(title: "垂直位置", value: verticalPositionBinding, range: 8...68, step: 1, suffix: "%")
            }

            SettingsGroup(title: "任务") {
                SliderRow(title: "行高", value: rowHeightBinding, range: 38...62, step: 1, suffix: "px")
                SliderRow(title: "行距", value: rowGapBinding, range: 4...16, step: 1, suffix: "px")
                SliderRow(title: "文字大小", value: textSizeBinding, range: 11...15, step: 0.5, suffix: "px")
            }

            SettingsGroup(title: "手感") {
                SliderRow(title: "动效", value: motionBinding, range: 80...520, step: 10, suffix: "ms")
                SliderRow(title: "圆角", value: cornerRadiusBinding, range: 10...30, step: 1, suffix: "px")
                SliderRow(title: "表面", value: surfaceOpacityBinding, range: 78...100, step: 1, suffix: "%")
            }
        }
    }

    private var header: some View {
        HStack {
            Text("任务设置")
                .font(.system(size: 20, weight: .bold))

            Spacer()

            Button {
                store.resetSettings()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("重置设置")

            Button {
                store.hideSettings()
            } label: {
                Image(systemName: "xmark")
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("关闭设置")
        }
    }

    private func themeButton(_ title: String, theme: TodoTheme) -> some View {
        Button {
            store.updateSettings { $0.theme = theme }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 42)
                .foregroundStyle(store.settings.theme == theme ? selectedThemeText : .secondary)
                .background(store.settings.theme == theme ? Color.primary : Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(.secondary.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var selectedThemeText: Color {
        store.settings.theme == .dark ? .black : .white
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
}

private struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.secondary)

            content
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                )
        }
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Text(valueText)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: range, step: step)
        }
    }

    private var valueText: String {
        if step < 1 {
            return String(format: "%.1f%@", value, suffix)
        }

        return "\(Int(value.rounded()))\(suffix)"
    }
}
