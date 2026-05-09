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
            let width = CGFloat(store.settings.panelWidth)

            ContentView()
                .environmentObject(store)
                .frame(width: width)
                .frame(minHeight: 760, idealHeight: 900)
                .preferredColorScheme(store.settings.theme == .dark ? .dark : .light)
                .clearWindowContainerBackground()
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
