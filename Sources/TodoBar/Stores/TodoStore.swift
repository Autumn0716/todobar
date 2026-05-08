import Combine
import Foundation
import TodoBarCore

@MainActor
final class TodoStore: ObservableObject {
    @Published private(set) var board: TodoBoard {
        didSet {
            save()
        }
    }

    private let storageKey = "TodoBar.board.v1"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: storageKey),
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
        board.isPanelOpen.toggle()
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

    func toggleSection(_ sectionID: String) {
        board.toggleSection(sectionID)
    }

    func addCustomList(title: String) {
        board.addCustomList(title: title)
    }

    func updateSettings(_ update: (inout TodoSettings) -> Void) {
        update(&board.settings)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(board) else {
            return
        }

        userDefaults.set(data, forKey: storageKey)
    }
}
