enum L {
    static var language: String = "zh"

    static func t(_ key: String) -> String {
        table[key]?[language] ?? key
    }

    private static let table: [String: [String: String]] = [
        // Settings header
        "settings.title": ["zh": "任务设置", "en": "Task Settings"],
        "settings.reset": ["zh": "重置设置", "en": "Reset Settings"],
        "settings.close": ["zh": "关闭设置", "en": "Close Settings"],

        // Settings tabs
        "settings.tab.general": ["zh": "通用", "en": "General"],
        "settings.tab.ui": ["zh": "界面", "en": "UI"],

        // General settings groups
        "settings.appearance": ["zh": "外观", "en": "Appearance"],
        "settings.theme.light": ["zh": "浅色", "en": "Light"],
        "settings.theme.dark": ["zh": "深色", "en": "Dark"],
        "settings.language": ["zh": "语言", "en": "Language"],
        "lang.zh": ["zh": "中文", "en": "中文"],
        "lang.en": ["zh": "EN", "en": "EN"],
        "settings.basics": ["zh": "基础", "en": "Basics"],
        "settings.doubleClickToggle": ["zh": "双击整行勾选任务", "en": "Double-click to toggle"],
        "settings.autoShowHide": ["zh": "自动显示/隐藏", "en": "Auto show/hide"],
        "settings.desktop": ["zh": "桌面", "en": "Desktop"],
        "settings.launchAtLogin": ["zh": "登录时启动", "en": "Launch at Login"],
        "settings.showDockIcon": ["zh": "在程序坞中显示", "en": "Show in Dock"],

        // UI settings groups
        "settings.window": ["zh": "窗口", "en": "Window"],
        "settings.panelWidth": ["zh": "面板宽度", "en": "Panel Width"],
        "settings.visibleTab": ["zh": "可见标签", "en": "Visible Tab"],
        "settings.handle": ["zh": "把手", "en": "Handle"],
        "settings.buttonHeight": ["zh": "按钮高度", "en": "Button Height"],
        "settings.verticalPos": ["zh": "垂直位置", "en": "Vertical Position"],
        "settings.tasks": ["zh": "任务", "en": "Tasks"],
        "settings.rowHeight": ["zh": "行高", "en": "Row Height"],
        "settings.rowGap": ["zh": "行距", "en": "Row Gap"],
        "settings.textSize": ["zh": "文字大小", "en": "Text Size"],
        "settings.feel": ["zh": "手感", "en": "Feel"],
        "settings.motion": ["zh": "动效", "en": "Motion"],
        "settings.cornerRadius": ["zh": "圆角", "en": "Corner Radius"],
        "settings.surface": ["zh": "表面", "en": "Surface"],

        // Panel
        "panel.openSettings": ["zh": "打开设置", "en": "Open Settings"],
        "panel.lists": ["zh": "清单", "en": "Lists"],
        "panel.customCount": ["zh": "个自定义", "en": "custom"],
        "panel.newList": ["zh": "新建清单...", "en": "New list..."],
        "panel.todayProgress": ["zh": "今日进度", "en": "Today's Progress"],
        "panel.doneOf": ["zh": "已完成 · 共", "en": "done · total"],
        "panel.taskCount": ["zh": "个任务", "en": "tasks"],

        // Task actions
        "task.markIncomplete": ["zh": "标记为未完成", "en": "Mark Incomplete"],
        "task.markComplete": ["zh": "标记为已完成", "en": "Mark Complete"],
        "task.delete": ["zh": "删除", "en": "Delete"],
        "task.deleted": ["zh": "已删除", "en": "Deleted"],
        "task.undo": ["zh": "撤销", "en": "Undo"],
        "task.undoMessage": ["zh": "已删除\"%@\"", "en": "Deleted \"%@\""],

        // Handle
        "handle.collapse": ["zh": "收起 TodoBar", "en": "Collapse TodoBar"],
        "handle.expand": ["zh": "展开 TodoBar", "en": "Expand TodoBar"],

        // Menu
        "menu.openSettings": ["zh": "打开设置", "en": "Open Settings"],
        "menu.resetSettings": ["zh": "重置设置", "en": "Reset Settings"],
    ]
}
