import SwiftUI
import TodoBarCore

struct TodoPanelView: View {
    @EnvironmentObject private var store: TodoStore

    var body: some View {
        VStack(alignment: .leading, spacing: 21) {
            header
            ProgressRibbonView()

            ForEach(store.sections.filter { $0.id == "today" || $0.id == "month" }) { section in
                TaskSectionView(section: section, countMode: section.id == "today" ? .done : .total)
            }

            listsSection
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.primary, Color.primary.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(nsColor: .windowBackgroundColor))
            }
            .frame(width: 36, height: 36)
            .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 4)

            Text("TodoBar")
                .font(.system(.title3, design: .rounded, weight: .bold))

            Spacer()

            Button {
                store.showSettings()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("打开设置")
        }
    }

    private var listsSection: some View {
        VStack(alignment: .leading, spacing: CGFloat(store.settings.rowGap)) {
            SectionHeaderView(
                symbolName: "checklist",
                title: "清单",
                countText: "\(store.customSections.count) 个自定义",
                isCollapsed: false,
                onToggle: { }
            )

            AddRowView(prompt: "新建清单...", symbolName: "checklist") { title in
                store.addCustomList(title: title)
            }

            ForEach(store.customSections) { section in
                CustomListView(section: section)
            }
        }
    }
}

private struct ProgressRibbonView: View {
    @EnvironmentObject private var store: TodoStore

    var body: some View {
        HStack(spacing: 10) {
            Label("今日进度", systemImage: "sparkles")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .controlSize(.small)

            Text("\(completedToday)/\(todayTotal)")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .glassRow(theme: store.settings.theme, radius: 14)
    }

    private var todayTasks: [TodoTask] {
        store.sections.first { $0.id == "today" }?.tasks ?? []
    }

    private var todayTotal: Int {
        max(todayTasks.count, 1)
    }

    private var completedToday: Int {
        todayTasks.filter(\.isCompleted).count
    }

    private var progress: Double {
        Double(completedToday) / Double(todayTotal)
    }
}

private enum CountMode {
    case done
    case total
}

private struct TaskSectionView: View {
    @EnvironmentObject private var store: TodoStore
    let section: TodoSection
    let countMode: CountMode

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(store.settings.rowGap)) {
            SectionHeaderView(
                symbolName: section.symbolName,
                title: section.title,
                countText: countText,
                isCollapsed: section.isCollapsed,
                onToggle: { store.toggleSection(section.id) }
            )

            if !section.isCollapsed {
                AddRowView(prompt: section.addPrompt, symbolName: "tray") { title in
                    store.addTask(to: section.id, title: title)
                }

                ForEach(section.tasks) { task in
                    TaskRowView(sectionID: section.id, task: task)
                }
            }
        }
    }

    private var countText: String {
        switch countMode {
        case .done:
            let doneCount = section.tasks.filter(\.isCompleted).count
            return "\(doneCount) 已完成 · 共 \(section.tasks.count)"
        case .total:
            return "\(section.tasks.count) 个任务"
        }
    }
}

private struct CustomListView: View {
    @EnvironmentObject private var store: TodoStore
    let section: TodoSection

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(store.settings.rowGap)) {
            Button {
                store.toggleSection(section.id)
            } label: {
                HStack(spacing: 8) {
                    Text(section.title)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)

                    Spacer()

                    Text("\(section.tasks.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)

                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 34)
                .glassRow(theme: store.settings.theme, radius: 10)
            }
            .buttonStyle(.plain)

            if !section.isCollapsed {
                ForEach(section.tasks) { task in
                    TaskRowView(sectionID: section.id, task: task)
                }

                AddRowView(prompt: section.addPrompt, symbolName: "tray") { title in
                    store.addTask(to: section.id, title: title)
                }
            }
        }
    }

}

private struct SectionHeaderView: View {
    let symbolName: String
    let title: String
    let countText: String
    let isCollapsed: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 19)

                Text(title)
                    .font(.system(size: 15, weight: .bold))

                Text(countText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityLabel(isCollapsed ? "展开\(title)" : "折叠\(title)")
            }
            .frame(minHeight: 34)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.primary, Color.primary.opacity(0.18)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
        }
    }
}

private struct AddRowView: View {
    @EnvironmentObject private var store: TodoStore
    let prompt: String
    let symbolName: String
    let onSubmit: (String) -> Void
    @State private var text = ""

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 23)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: CGFloat(store.settings.textSize + 1), weight: .semibold))
                .onSubmit(submit)

            Button(action: submit) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel(prompt)
        }
        .padding(.horizontal, 11)
        .frame(minHeight: CGFloat(store.settings.rowHeight))
        .glassRow(theme: store.settings.theme, radius: 12)
    }

    private func submit() {
        onSubmit(text)
        text = ""
    }
}

private struct TaskRowView: View {
    @EnvironmentObject private var store: TodoStore
    let sectionID: String
    let task: TodoTask

    var body: some View {
        HStack(spacing: 8) {
            Button {
                store.toggleTask(sectionID: sectionID, taskID: task.id)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: task.isCompleted ? 7 : 999, style: .continuous)
                        .stroke(.secondary.opacity(0.35), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: task.isCompleted ? 7 : 999, style: .continuous)
                                .fill(task.isCompleted ? Color.secondary.opacity(0.08) : Color.clear)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "标记为未完成" : "标记为已完成")

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: CGFloat(store.settings.textSize + 1.5), weight: .bold))
                    .lineLimit(1)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                Text(task.detail)
                    .font(.system(size: CGFloat(store.settings.textSize), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Circle()
                .fill(task.isFocused ? Color.primary : Color.secondary.opacity(0.5))
                .frame(width: 7, height: 7)

            Button {
                store.deleteTask(sectionID: sectionID, taskID: task.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("删除\(task.title)")
        }
        .padding(.horizontal, 11)
        .frame(minHeight: CGFloat(store.settings.rowHeight))
        .glassRow(theme: store.settings.theme, radius: 12)
    }
}

private extension View {
    func glassRow(theme: TodoTheme, radius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return self
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    shape.fill(theme == .dark ? Color.white.opacity(0.035) : Color.white.opacity(0.34))
                }
            }
            .overlay(
                shape.stroke(theme == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.58), lineWidth: 1)
            )
            .clipShape(shape)
            .shadow(color: .black.opacity(theme == .dark ? 0.20 : 0.07), radius: 10, x: 0, y: 4)
    }
}
