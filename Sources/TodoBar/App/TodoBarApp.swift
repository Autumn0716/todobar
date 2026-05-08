import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct TodoBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = TodoStore()

    var body: some Scene {
        WindowGroup("TodoBar") {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 420, idealWidth: 560, minHeight: 760, idealHeight: 900)
                .preferredColorScheme(store.settings.theme == .dark ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("TodoBar") {
                Button("打开设置") {
                    store.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)

                Button("重置设置") {
                    store.resetSettings()
                }
            }
        }
    }
}
