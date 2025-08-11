import AppKit
import SwiftUI

final class StatusBarController {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init() {
        if let button = item.button { button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: nil) }
        constructMenu()
    }

    private func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh Now Playing", action: #selector(refresh), keyEquivalent: "r"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Play/Pause", action: #selector(toggle), keyEquivalent: " "))
        menu.addItem(NSMenuItem(title: "Next", action: #selector(nextTrack), keyEquivalent: "]"))
        menu.addItem(NSMenuItem(title: "Previous", action: #selector(prevTrack), keyEquivalent: "["))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }
        item.menu = menu
    }

    @objc private func refresh() { NowPlayingService.shared.refreshNowPlaying() }
    @objc private func toggle() { NowPlayingService.shared.togglePlayPause() }
    @objc private func nextTrack() { NowPlayingService.shared.nextTrack() }
    @objc private func prevTrack() { NowPlayingService.shared.previousTrack() }
    @objc private func quit() { NSApp.terminate(nil) }
}
