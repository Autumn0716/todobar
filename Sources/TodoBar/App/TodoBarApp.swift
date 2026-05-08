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
            let width = CGFloat(store.settings.panelWidth + store.settings.visibleTab)

            ContentView()
                .environmentObject(store)
                .frame(width: width)
                .frame(minHeight: 760, idealHeight: 900)
                .preferredColorScheme(store.settings.theme == .dark ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 382, height: 860)
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
