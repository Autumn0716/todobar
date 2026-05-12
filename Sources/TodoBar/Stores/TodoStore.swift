import Combine
import Foundation
import SwiftUI
import TodoBarCore

enum TodoStorage {
    static let boardKey = "TodoBar.board.v1"
}

@MainActor
final class TodoStore: ObservableObject {
    @Published var isInteracting = false
    @Published var isHandleHovered = false
    @Published var isHandlePressed = false

    @Published private(set) var board: TodoBoard {
        didSet {
            scheduleSave()
        }
    }

    private var saveTask: Task<Void, Never>?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: TodoStorage.boardKey),
           let decoded = try? JSONDecoder().decode(TodoBoard.self, from: data) {
            self.board = decoded
        } else {
            self.board = .sampleChinese()
        }
    }

    private let userDefaults: UserDefaults

    var sections: [TodoSection] {
        board.sections
    }

    var settings: TodoSettings {
        board.settings
    }

    var customSections: [TodoSection] {
        board.sections.filter { board.customListIDs.contains($0.id) }
    }

    func togglePanel() {
        cancelAutoClose()
        board.isPanelOpen.toggle()
    }

    func openPanel() {
        cancelAutoClose()
        board.isPanelOpen = true
    }

    func closePanel() {
        cancelAutoClose()
        board.isPanelOpen = false
    }

    func showSettings() {
        board.isSettingsOpen = true
    }

    func hideSettings() {
        board.isSettingsOpen = false
    }

    func resetSettings() {
        board.settings = TodoSettings()
    }

    func addTask(to sectionID: String, title: String) {
        board.addTask(to: sectionID, title: title)
    }

    func toggleTask(sectionID: String, taskID: String) {
        board.toggleTask(sectionID: sectionID, taskID: taskID)
    }

    func deleteTask(sectionID: String, taskID: String) {
        board.deleteTask(sectionID: sectionID, taskID: taskID)
    }

    func reinsertTask(sectionID: String, task: TodoTask, at index: Int) {
        board.reinsertTask(sectionID: sectionID, task: task, at: index)
    }

    func toggleSection(_ sectionID: String) {
        board.toggleSection(sectionID)
    }

    func reorderTask(sectionID: String, draggedID: String, targetID: String) {
        board.reorderTask(sectionID: sectionID, draggedID: draggedID, targetID: targetID)
    }

    func addCustomList(title: String) {
        board.addCustomList(title: title)
    }

    func updateSettings(_ update: (inout TodoSettings) -> Void) {
        update(&board.settings)
    }

    @Published private var autoCloseTask: Task<Void, Never>? = nil
    @Published var isMouseInProximity = false {
        didSet {
            if isMouseInProximity {
                cancelAutoClose()
            } else if board.isPanelOpen && settings.autoShowHide {
                scheduleAutoClose()
            }
        }
    }

    func cancelAutoClose() {
        autoCloseTask?.cancel()
        autoCloseTask = nil
    }

    func scheduleAutoClose() {
        cancelAutoClose()
        let motionMs = settings.motionMs
        autoCloseTask = Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // Slightly longer 800ms for better UX
            guard !Task.isCancelled && !isMouseInProximity else { return }
            await MainActor.run {
                withAnimation(.spring(response: motionMs / 1000, dampingFraction: 0.78)) {
                    self.closePanel()
                }
            }
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            save()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(board) else {
            return
        }

        userDefaults.set(data, forKey: TodoStorage.boardKey)
    }
}
