import Foundation
import Testing
@testable import TodoBarCore

@Test func addTaskCreatesIncompleteChineseTask() {
    var board = TodoBoard.sampleChinese()

    board.addTask(to: "today", title: "  写发布说明  ")

    #expect(board.sections[0].tasks.last?.title == "写发布说明")
    #expect(board.sections[0].tasks.last?.detail == "今天")
    #expect(board.sections[0].tasks.last?.isCompleted == false)
}

@Test func toggleAndDeleteTaskUpdatesRequestedSectionOnly() {
    var board = TodoBoard.sampleChinese()
    let taskID = board.sections[0].tasks[0].id

    board.toggleTask(sectionID: "today", taskID: taskID)
    board.deleteTask(sectionID: "today", taskID: taskID)

    #expect(board.sections[0].tasks.contains { $0.id == taskID } == false)
    #expect(board.sections[1].tasks.count == 2)
}

@Test func customListHasStableChineseTitleAndEmptyTasks() {
    var board = TodoBoard.sampleChinese()

    board.addCustomList(title: "深度工作")

    #expect(board.customListIDs.last == "深度工作")
    #expect(board.sections.last?.title == "深度工作")
    #expect(board.sections.last?.tasks.isEmpty == true)
}

@Test func dockIconSettingDefaultsToVisible() {
    let settings = TodoSettings()

    #expect(settings.showDockIcon == true)
}

@Test func dockIconSettingKeepsExplicitHiddenValue() throws {
    let settings = TodoSettings(showDockIcon: false)
    let data = try JSONEncoder().encode(settings)
    let decoded = try JSONDecoder().decode(TodoSettings.self, from: data)

    #expect(decoded.showDockIcon == false)
}

@Test func legacySettingsWithoutDockIconDecodeAsVisible() throws {
    let legacyJSON = #"""
    {
      "theme": "light",
      "launchAtLogin": true,
      "panelWidth": 348,
      "visibleTab": 34,
      "buttonHeight": 72,
      "verticalPosition": 16,
      "rowHeight": 41,
      "rowGap": 7,
      "textSize": 12.5,
      "motionMs": 230,
      "cornerRadius": 18,
      "surfaceOpacity": 96,
      "doubleClickToToggle": true,
      "language": "zh",
      "autoShowHide": false,
      "activeTab": "general"
    }
    """#.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(TodoSettings.self, from: legacyJSON)

    #expect(decoded.showDockIcon == true)
}
