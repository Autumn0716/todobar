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
