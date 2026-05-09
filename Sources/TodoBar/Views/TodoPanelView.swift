import SwiftUI
import UniformTypeIdentifiers
import TodoBarCore

struct TodoPanelView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme

    @State private var pendingUndoTask: TodoTask?
    @State private var pendingUndoSectionID: String?
    @State private var pendingUndoIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            ProgressRibbonView()

            ForEach(store.sections.filter { $0.id == "today" || $0.id == "month" }) { section in
                TaskSectionView(section: section, countMode: section.id == "today" ? .done : .total, onTaskDeleted: handleTaskDeleted)
            }

            listsSection
        }
        .overlay(alignment: .bottom) {
            if pendingUndoTask != nil {
                UndoBar(
                    title: String(format: L.t("task.undoMessage"), pendingUndoTask?.title ?? ""),
                    onUndo: undoDelete
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.16), value: pendingUndoTask)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.ink, theme.ink.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(theme.surface)
            }
            .frame(width: 36, height: 36)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            Text("TodoBar")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(theme.ink)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    store.showSettings()
                }
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .fluidButton()
            .foregroundStyle(theme.muted)
            .accessibilityLabel(L.t("panel.openSettings"))
        }
    }

    private var listsSection: some View {
        VStack(alignment: .leading, spacing: CGFloat(store.settings.rowGap)) {
            SectionHeaderView(
                symbolName: "checklist",
                title: L.t("panel.lists"),
                countText: "\(store.customSections.count) \(L.t("panel.customCount"))",
                isCollapsed: false,
                onToggle: { }
            )

            AddRowView(prompt: L.t("panel.newList"), symbolName: "checklist") { title in
                store.addCustomList(title: title)
            }

            ForEach(store.customSections) { section in
                CustomListView(section: section, onTaskDeleted: handleTaskDeleted)
            }
        }
    }

    private func handleTaskDeleted(sectionID: String, task: TodoTask, index: Int) {
        pendingUndoTask = task
        pendingUndoSectionID = sectionID
        pendingUndoIndex = index

        withAnimation(.spring(response: 0.22, dampingFraction: 0.85)) {
            store.deleteTask(sectionID: sectionID, taskID: task.id)
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if pendingUndoTask?.id == task.id {
                withAnimation(.easeOut(duration: 0.16)) {
                    pendingUndoTask = nil
                    pendingUndoSectionID = nil
                    pendingUndoIndex = nil
                }
            }
        }
    }

    private func undoDelete() {
        guard let task = pendingUndoTask,
              let sectionID = pendingUndoSectionID,
              let index = pendingUndoIndex else { return }

        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            store.reinsertTask(sectionID: sectionID, task: task, at: index)
            pendingUndoTask = nil
            pendingUndoSectionID = nil
            pendingUndoIndex = nil
        }
    }
}

private struct ProgressRibbonView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme

    var body: some View {
        HStack(spacing: 10) {
            Label(L.t("panel.todayProgress"), systemImage: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.muted)

            ProgressView(value: progress)
                .controlSize(.small)
                .tint(theme.ink)

            Text("\(completedToday)/\(todayTotal)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .glassRow(theme: theme, radius: 14)
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
    let onTaskDeleted: (String, TodoTask, Int) -> Void
    @State private var draggedTask: TodoTask?
    @State private var dragOffset: CGFloat = 0
    @State private var targetIndex: Int?
    @State private var deletingIDs: Set<String> = []

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

                ForEach(Array(section.tasks.enumerated()), id: \.element.id) { index, task in
                    let isDragged = draggedTask?.id == task.id
                    TaskRowView(
                        sectionID: section.id,
                        task: task,
                        isDeleting: deletingIDs.contains(task.id),
                        onDelete: { deleteTask(task) }
                    )
                    .offset(y: offsetForTask(at: index))
                    .zIndex(isDragged ? 1 : 0)
                    .scaleEffect(isDragged ? 1.02 : 1)
                    .opacity(isDragged ? 0.9 : 1)
                    .animation(isDragged ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: targetIndex)
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                if draggedTask == nil {
                                    draggedTask = task
                                    targetIndex = index
                                }
                                dragOffset = value.translation.height
                                recalcTarget()
                            }
                            .onEnded { _ in
                                commitReorder()
                                draggedTask = nil
                                dragOffset = 0
                                targetIndex = nil
                            }
                    )
                }
            }
        }
    }

    private var countText: String {
        switch countMode {
        case .done:
            let doneCount = section.tasks.filter(\.isCompleted).count
            return "\(doneCount) \(L.t("panel.doneOf")) \(section.tasks.count)"
        case .total:
            return "\(section.tasks.count) \(L.t("panel.taskCount"))"
        }
    }

    private var rowStride: CGFloat {
        CGFloat(store.settings.rowHeight) + CGFloat(store.settings.rowGap)
    }

    private func recalcTarget() {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }) else { return }
        let movedRows = Int(round(dragOffset / rowStride))
        let newTarget = max(0, min(section.tasks.count - 1, dragIndex + movedRows))
        targetIndex = newTarget
    }

    private func offsetForTask(at index: Int) -> CGFloat {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }),
              let target = targetIndex else { return 0 }

        if section.tasks[index].id == draggedTask.id {
            return dragOffset
        }

        if dragIndex < target {
            if index > dragIndex && index <= target {
                return -rowStride
            }
        } else if dragIndex > target {
            if index >= target && index < dragIndex {
                return rowStride
            }
        }

        return 0
    }

    private func commitReorder() {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }),
              let target = targetIndex,
              dragIndex != target else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            store.reorderTask(sectionID: section.id, draggedID: draggedTask.id, targetID: section.tasks[target].id)
        }
    }

    private func deleteTask(_ task: TodoTask) {
        guard !deletingIDs.contains(task.id),
              let index = section.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        withAnimation(.spring(response: 0.15, dampingFraction: 0.88)) {
            _ = deletingIDs.insert(task.id)
        }

        onTaskDeleted(section.id, task, index)
        deletingIDs.remove(task.id)
    }
}

private struct CustomListView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme
    let section: TodoSection
    let onTaskDeleted: (String, TodoTask, Int) -> Void
    @State private var draggedTask: TodoTask?
    @State private var dragOffset: CGFloat = 0
    @State private var targetIndex: Int?
    @State private var deletingIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(store.settings.rowGap)) {
            Button {
                store.toggleSection(section.id)
            } label: {
                HStack(spacing: 8) {
                    Text(section.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)

                    Spacer()

                    Text("\(section.tasks.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.muted)

                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(theme.muted)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 34)
                .glassRow(theme: theme, radius: 10)
            }
            .fluidButton()

            if !section.isCollapsed {
                ForEach(Array(section.tasks.enumerated()), id: \.element.id) { index, task in
                    let isDragged = draggedTask?.id == task.id
                    TaskRowView(
                        sectionID: section.id,
                        task: task,
                        isDeleting: deletingIDs.contains(task.id),
                        onDelete: { deleteTask(task) }
                    )
                    .offset(y: offsetForTask(at: index))
                    .zIndex(isDragged ? 1 : 0)
                    .scaleEffect(isDragged ? 1.02 : 1)
                    .opacity(isDragged ? 0.9 : 1)
                    .animation(isDragged ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: targetIndex)
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                if draggedTask == nil {
                                    draggedTask = task
                                    targetIndex = index
                                }
                                dragOffset = value.translation.height
                                recalcTarget()
                            }
                            .onEnded { _ in
                                commitReorder()
                                draggedTask = nil
                                dragOffset = 0
                                targetIndex = nil
                            }
                    )
                }

                AddRowView(prompt: section.addPrompt, symbolName: "tray") { title in
                    store.addTask(to: section.id, title: title)
                }
            }
        }
    }

    private var rowStride: CGFloat {
        CGFloat(store.settings.rowHeight) + CGFloat(store.settings.rowGap)
    }

    private func recalcTarget() {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }) else { return }
        let movedRows = Int(round(dragOffset / rowStride))
        let newTarget = max(0, min(section.tasks.count - 1, dragIndex + movedRows))
        targetIndex = newTarget
    }

    private func offsetForTask(at index: Int) -> CGFloat {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }),
              let target = targetIndex else { return 0 }

        if section.tasks[index].id == draggedTask.id {
            return dragOffset
        }

        if dragIndex < target {
            if index > dragIndex && index <= target {
                return -rowStride
            }
        } else if dragIndex > target {
            if index >= target && index < dragIndex {
                return rowStride
            }
        }

        return 0
    }

    private func commitReorder() {
        guard let draggedTask,
              let dragIndex = section.tasks.firstIndex(where: { $0.id == draggedTask.id }),
              let target = targetIndex,
              dragIndex != target else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            store.reorderTask(sectionID: section.id, draggedID: draggedTask.id, targetID: section.tasks[target].id)
        }
    }

    private func deleteTask(_ task: TodoTask) {
        guard !deletingIDs.contains(task.id),
              let index = section.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        withAnimation(.spring(response: 0.15, dampingFraction: 0.88)) {
            _ = deletingIDs.insert(task.id)
        }

        onTaskDeleted(section.id, task, index)
        deletingIDs.remove(task.id)
    }
}

private struct SectionHeaderView: View {
    @Environment(\.webTheme) private var theme
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
                    .foregroundStyle(theme.ink)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.ink)

                Text(countText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.muted)
                    .lineLimit(1)

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .fluidButton()
                .foregroundStyle(theme.muted)
                .accessibilityLabel(isCollapsed ? "\(L.t("handle.expand")) \(title)" : "\(L.t("handle.collapse")) \(title)")
            }
            .frame(minHeight: 34)

            Capsule()
                .fill(theme.accent)
                .frame(height: 2)
        }
        .padding(.bottom, 9)
    }
}

private struct AddRowView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme
    let prompt: String
    let symbolName: String
    let onSubmit: (String) -> Void
    @State private var text = ""

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(theme.muted)
                .frame(width: 26)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: CGFloat(store.settings.textSize + 1), weight: .semibold))
                .foregroundStyle(theme.ink)
                .onSubmit(submit)

            Button(action: submit) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
            .fluidButton()
            .foregroundStyle(theme.muted)
            .accessibilityLabel(prompt)
        }
        .padding(.horizontal, 7)
        .padding(.leading, 4)
        .frame(minHeight: CGFloat(store.settings.rowHeight))
        .glassRow(theme: theme, radius: 10)
    }

    private func submit() {
        if !text.isEmpty {
            onSubmit(text)
            text = ""
        }
    }
}

private struct TaskRowView: View {
    @EnvironmentObject private var store: TodoStore
    @Environment(\.webTheme) private var theme
    let sectionID: String
    let task: TodoTask
    let isDeleting: Bool
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 6) {
            Button {
                store.toggleTask(sectionID: sectionID, taskID: task.id)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: task.isCompleted ? 7 : 999, style: .continuous)
                        .stroke(theme.lineStrong, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: task.isCompleted ? 7 : 999, style: .continuous)
                                .fill(task.isCompleted ? theme.surfaceSoft : Color.clear)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(theme.ink)
                    }
                }
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
            }
            .fluidButton()
            .accessibilityLabel(task.isCompleted ? L.t("task.markIncomplete") : L.t("task.markComplete"))
            .scaleEffect(isDeleting ? 0.5 : 1)
            .opacity(isDeleting ? 0 : 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: CGFloat(store.settings.textSize + 1.5), weight: .semibold))
                    .lineLimit(1)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? theme.muted : theme.ink)

                Text(task.detail)
                    .font(.system(size: CGFloat(store.settings.textSize), weight: .medium))
                    .foregroundStyle(theme.muted)
                    .lineLimit(1)
            }
            .opacity(isDeleting ? 0 : 1)
            .offset(x: isDeleting ? 12 : 0)

            Spacer()

            ZStack {
                if isHovering && !isDeleting {
                    TaskDeleteButton(isDeleting: isDeleting, action: onDelete)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                } else if !isDeleting {
                    Circle()
                        .fill(task.isFocused ? theme.ink : theme.lineStrong)
                        .frame(width: 7, height: 7)
                }
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 7)
        .padding(.leading, 4)
        .frame(minHeight: CGFloat(store.settings.rowHeight))
        .glassRow(theme: theme, radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isHovering ? theme.lineStrong : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isDeleting ? 0.96 : (isHovering ? 0.985 : 1))
        .offset(x: isDeleting ? 20 : 0, y: isHovering ? -1 : 0)
        .blur(radius: isDeleting ? 1.2 : 0)
        .opacity(isDeleting ? 0 : 1)
        .animation(.spring(response: 0.15, dampingFraction: 0.88), value: isDeleting)
        .animation(.easeOut(duration: 0.12), value: isHovering)
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded {
                    if store.settings.doubleClickToToggle {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            store.toggleTask(sectionID: sectionID, taskID: task.id)
                        }
                    }
                }
        )
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hover
            }
        }
    }
}

private extension View {
    func glassRow(theme: WebTheme, radius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return self
            .background(theme.surfaceRaised)
            .clipShape(shape)
            .overlay(
                shape.stroke(theme.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }
}
