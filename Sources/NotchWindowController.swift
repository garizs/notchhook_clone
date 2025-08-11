import AppKit
import SwiftUI

final class NotchWindowController: NSWindowController {
    private var hosting: NSHostingView<NotchView>

    init(rootView: NotchView) {
        hosting = NSHostingView(rootView: rootView)
        let window = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .statusBar
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = hosting
        super.init(window: window)
        positionWindow()
        NotificationCenter.default.addObserver(self, selector: #selector(screenChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func show() {
        guard let window = self.window else { return }
        positionWindow()
        window.orderFrontRegardless()
    }

    @objc private func screenChanged() { positionWindow() }

    private func positionWindow() {
        guard let screen = NSScreen.main, let window = self.window else { return }
        hosting.layoutSubtreeIfNeeded()
        let size = hosting.fittingSize
        let topInset: CGFloat = 10
        let x = screen.frame.midX - size.width / 2
        let y = screen.frame.maxY - size.height - topInset
        window.setFrame(NSRect(x: x, y: y, width: size.width, height: size.height), display: true)
    }
}
