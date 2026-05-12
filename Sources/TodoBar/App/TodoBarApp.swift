import AppKit
import SwiftUI
import TodoBarCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        applyDockIconVisibility(Self.initialDockIconVisibility(), activatesRegularApp: false)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if Self.initialDockIconVisibility() {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applyDockIconVisibility(_ isVisible: Bool, activatesRegularApp: Bool = true) {
        NSApp.setActivationPolicy(isVisible ? .regular : .accessory)
        if isVisible && activatesRegularApp {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private static func initialDockIconVisibility(userDefaults: UserDefaults = .standard) -> Bool {
        guard let data = userDefaults.data(forKey: TodoStorage.boardKey),
              let board = try? JSONDecoder().decode(TodoBoard.self, from: data) else {
            return true
        }

        return board.settings.showDockIcon
    }
}

@main
struct TodoBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = TodoStore()

    var body: some Scene {
        WindowGroup("TodoBar") {
            let width = CGFloat(store.settings.panelWidth)

            ContentView()
                .environmentObject(store)
                .frame(width: width)
                .frame(minHeight: 760, idealHeight: 900)
                .preferredColorScheme(store.settings.theme == .dark ? .dark : .light)
                .clearWindowContainerBackground()
                .onAppear {
                    appDelegate.applyDockIconVisibility(store.settings.showDockIcon)
                }
                .onChange(of: store.settings.showDockIcon) { _, isVisible in
                    appDelegate.applyDockIconVisibility(isVisible)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 382, height: 860)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("TodoBar") {
                Button(L.t("menu.openSettings")) {
                    store.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)

                Button(L.t("menu.resetSettings")) {
                    store.resetSettings()
                }
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func clearWindowContainerBackground() -> some View {
        if #available(macOS 15.0, *) {
            self.containerBackground(.clear, for: .window)
        } else {
            self
        }
    }
}
