import Foundation

public enum TodoTheme: String, Codable, Equatable, Sendable {
    case light
    case dark
}

public struct TodoTask: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var detail: String
    public var isCompleted: Bool
    public var isFocused: Bool

    public init(
        id: String,
        title: String,
        detail: String,
        isCompleted: Bool = false,
        isFocused: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isCompleted = isCompleted
        self.isFocused = isFocused
    }
}

public struct TodoSection: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var symbolName: String
    public var addPrompt: String
    public var tasks: [TodoTask]
    public var isCollapsed: Bool

    public init(
        id: String,
        title: String,
        symbolName: String,
        addPrompt: String,
        tasks: [TodoTask] = [],
        isCollapsed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.addPrompt = addPrompt
        self.tasks = tasks
        self.isCollapsed = isCollapsed
    }
}

public enum SettingsTab: String, Codable, Equatable, Sendable {
    case general
    case ui
}

public struct TodoSettings: Codable, Equatable, Sendable {
    public var theme: TodoTheme
    public var launchAtLogin: Bool
    public var showDockIcon: Bool
    public var panelWidth: Double
    public var visibleTab: Double
    public var buttonHeight: Double
    public var verticalPosition: Double
    public var rowHeight: Double
    public var rowGap: Double
    public var textSize: Double
    public var motionMs: Double
    public var cornerRadius: Double
    public var surfaceOpacity: Double
    public var doubleClickToToggle: Bool
    public var language: String
    public var autoShowHide: Bool
    public var activeTab: SettingsTab

    private enum CodingKeys: String, CodingKey {
        case theme
        case launchAtLogin
        case showDockIcon
        case panelWidth
        case visibleTab
        case buttonHeight
        case verticalPosition
        case rowHeight
        case rowGap
        case textSize
        case motionMs
        case cornerRadius
        case surfaceOpacity
        case doubleClickToToggle
        case language
        case autoShowHide
        case activeTab
    }

    public init(
        theme: TodoTheme = .light,
        launchAtLogin: Bool = true,
        showDockIcon: Bool = true,
        panelWidth: Double = 348,
        visibleTab: Double = 34,
        buttonHeight: Double = 72,
        verticalPosition: Double = 16,
        rowHeight: Double = 41,
        rowGap: Double = 7,
        textSize: Double = 12.5,
        motionMs: Double = 230,
        cornerRadius: Double = 18,
        surfaceOpacity: Double = 96,
        doubleClickToToggle: Bool = true,
        language: String = "zh",
        autoShowHide: Bool = false,
        activeTab: SettingsTab = .general
    ) {
        self.theme = theme
        self.launchAtLogin = launchAtLogin
        self.showDockIcon = showDockIcon
        self.panelWidth = panelWidth
        self.visibleTab = visibleTab
        self.buttonHeight = buttonHeight
        self.verticalPosition = verticalPosition
        self.rowHeight = rowHeight
        self.rowGap = rowGap
        self.textSize = textSize
        self.motionMs = motionMs
        self.cornerRadius = cornerRadius
        self.surfaceOpacity = surfaceOpacity
        self.doubleClickToToggle = doubleClickToToggle
        self.language = language
        self.autoShowHide = autoShowHide
        self.activeTab = activeTab
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decode(TodoTheme.self, forKey: .theme)
        launchAtLogin = try container.decode(Bool.self, forKey: .launchAtLogin)
        showDockIcon = try container.decodeIfPresent(Bool.self, forKey: .showDockIcon) ?? true
        panelWidth = try container.decode(Double.self, forKey: .panelWidth)
        visibleTab = try container.decode(Double.self, forKey: .visibleTab)
        buttonHeight = try container.decode(Double.self, forKey: .buttonHeight)
        verticalPosition = try container.decode(Double.self, forKey: .verticalPosition)
        rowHeight = try container.decode(Double.self, forKey: .rowHeight)
        rowGap = try container.decode(Double.self, forKey: .rowGap)
        textSize = try container.decode(Double.self, forKey: .textSize)
        motionMs = try container.decode(Double.self, forKey: .motionMs)
        cornerRadius = try container.decode(Double.self, forKey: .cornerRadius)
        surfaceOpacity = try container.decode(Double.self, forKey: .surfaceOpacity)
        doubleClickToToggle = try container.decode(Bool.self, forKey: .doubleClickToToggle)
        language = try container.decode(String.self, forKey: .language)
        autoShowHide = try container.decode(Bool.self, forKey: .autoShowHide)
        activeTab = try container.decode(SettingsTab.self, forKey: .activeTab)
    }
}

public struct TodoBoard: Codable, Equatable, Sendable {
    public var sections: [TodoSection]
    public var customListIDs: [String]
    public var settings: TodoSettings
    public var isPanelOpen: Bool
    public var isSettingsOpen: Bool

    public init(
        sections: [TodoSection],
        customListIDs: [String],
        settings: TodoSettings = TodoSettings(),
        isPanelOpen: Bool = true,
        isSettingsOpen: Bool = false
    ) {
        self.sections = sections
        self.customListIDs = customListIDs
        self.settings = settings
        self.isPanelOpen = isPanelOpen
        self.isSettingsOpen = isSettingsOpen
    }

    public static func sampleChinese() -> TodoBoard {
        TodoBoard(
            sections: [
                TodoSection(
                    id: "today",
                    title: "今天",
                    symbolName: "clock",
                    addPrompt: "添加任务...",
                    tasks: [
                        TodoTask(
                            id: "task-design-sidebar-shell",
                            title: "设计侧边栏外壳",
                            detail: "今天 · 40 分钟",
                            isFocused: true
                        ),
                        TodoTask(
                            id: "task-prototype-desktop-shortcut",
                            title: "原型化桌面快捷入口",
                            detail: "今天 · 原生钩子"
                        ),
                        TodoTask(
                            id: "task-test",
                            title: "测试",
                            detail: "今天",
                            isCompleted: true
                        ),
                        TodoTask(
                            id: "task-capture-inbox",
                            title: "捕获收件箱",
                            detail: "快速添加",
                            isCompleted: true
                        )
                    ]
                ),
                TodoSection(
                    id: "month",
                    title: "月计划",
                    symbolName: "calendar",
                    addPrompt: "添加月任务...",
                    tasks: [
                        TodoTask(
                            id: "task-open-source-roadmap",
                            title: "开源路线图",
                            detail: "五月 · 里程碑 0.1",
                            isFocused: true
                        ),
                        TodoTask(
                            id: "task-later",
                            title: "稍后",
                            detail: "先把想法放在这里"
                        )
                    ]
                ),
                TodoSection(
                    id: "general",
                    title: "通用",
                    symbolName: "checklist",
                    addPrompt: "添加任务..."
                )
            ],
            customListIDs: ["general"]
        )
    }

    public mutating func addTask(to sectionID: String, title rawTitle: String) {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }) else {
            return
        }

        let existingIDs = sections[sectionIndex].tasks.map(\.id)
        let task = TodoTask(
            id: uniqueID(base: "task-\(slugify(title))", existingIDs: existingIDs),
            title: title,
            detail: sectionID == "month" ? "五月 · 已规划" : "今天"
        )
        sections[sectionIndex].tasks.append(task)
    }

    public mutating func toggleTask(sectionID: String, taskID: String) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }),
              let taskIndex = sections[sectionIndex].tasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        sections[sectionIndex].tasks[taskIndex].isCompleted.toggle()
    }

    public mutating func deleteTask(sectionID: String, taskID: String) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }) else {
            return
        }

        sections[sectionIndex].tasks.removeAll { $0.id == taskID }
    }

    public mutating func reinsertTask(sectionID: String, task: TodoTask, at index: Int) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }) else {
            return
        }
        let clampedIndex = min(index, sections[sectionIndex].tasks.count)
        sections[sectionIndex].tasks.insert(task, at: clampedIndex)
    }

    public mutating func toggleSection(_ sectionID: String) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }) else {
            return
        }

        sections[sectionIndex].isCollapsed.toggle()
    }

    public mutating func reorderTask(sectionID: String, draggedID: String, targetID: String) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionID }),
              let fromIndex = sections[sectionIndex].tasks.firstIndex(where: { $0.id == draggedID }),
              let toIndex = sections[sectionIndex].tasks.firstIndex(where: { $0.id == targetID }),
              fromIndex != toIndex else {
            return
        }
        let task = sections[sectionIndex].tasks.remove(at: fromIndex)
        sections[sectionIndex].tasks.insert(task, at: toIndex)
    }

    public mutating func addCustomList(title rawTitle: String) {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            return
        }

        let existingIDs = sections.map(\.id)
        let id = uniqueID(base: slugify(title), existingIDs: existingIDs)
        sections.append(
            TodoSection(
                id: id,
                title: title,
                symbolName: "checklist",
                addPrompt: "添加任务..."
            )
        )
        customListIDs.append(id)
    }
}

private func uniqueID(base: String, existingIDs: [String]) -> String {
    let normalizedBase = base.isEmpty ? "item" : base
    let existing = Set(existingIDs)
    var candidate = normalizedBase
    var suffix = 2

    while existing.contains(candidate) {
        candidate = "\(normalizedBase)-\(suffix)"
        suffix += 1
    }

    return candidate
}

private func slugify(_ value: String) -> String {
    let transformed = value
        .lowercased()
        .replacingOccurrences(of: "[^a-z0-9\\p{Han}]+", with: "-", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

    return transformed.isEmpty ? "item" : transformed
}
