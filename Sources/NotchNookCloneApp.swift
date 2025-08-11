import SwiftUI

@main
struct NotchNookCloneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings { SettingsView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var notchWindowController: NotchWindowController!
    private let nowPlaying = NowPlayingService.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController()
        notchWindowController = NotchWindowController(rootView: NotchView())
        notchWindowController.show()
        nowPlaying.start()
    }
}
