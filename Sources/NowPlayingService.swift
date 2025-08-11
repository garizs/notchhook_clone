import Foundation
import AppKit

final class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var appBundleID: String = ""
    @Published var artworkImage: NSImage? = nil
    @Published var isPlaying: Bool = false
    @Published var duration: Double = 0
    @Published var position: Double = 0

    private var timer: Timer?

    func start() {
        MRRegisterForNowPlayingNotifications()
        refreshNowPlaying()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMRNotification(_:)), name: .mrNowPlayingInfoDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMRNotification(_:)), name: .mrIsPlayingDidChange, object: nil)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.isPlaying, self.duration > 0, self.position < self.duration {
                self.position += 0.5
            }
        }
    }

    func stop() {
        MRUnregisterForNowPlayingNotifications()
        timer?.invalidate()
        timer = nil
    }

    @objc private func handleMRNotification(_ n: Notification) {
        refreshNowPlaying()
    }

    func refreshNowPlaying() {
        MRBridgeGetNowPlayingInfo { info in
            DispatchQueue.main.async {
                self.apply(info: info)
            }
        }
        MRBridgeGetIsPlaying { playing in
            DispatchQueue.main.async { self.isPlaying = playing }
        }
    }

    private func apply(info: [String: Any]) {
        title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
        let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String
        let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String
        subtitle = [artist, album].compactMap { $0 }.joined(separator: " • ")
        appBundleID = info["kMRMediaRemoteNowPlayingInfoClientBundleIdentifier"] as? String ?? ""

        if let artData = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data, let img = NSImage(data: artData) {
            artworkImage = img
        } else {
            artworkImage = nil
        }

        duration = (info["kMRMediaRemoteNowPlayingInfoDuration"] as? NSNumber)?.doubleValue ?? 0
        position = (info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? NSNumber)?.doubleValue ?? 0
    }

    // MARK: - Controls
    func togglePlayPause() { MRSentCommand(.togglePlayPause) }
    func nextTrack() { MRSentCommand(.nextTrack) }
    func previousTrack() { MRSentCommand(.previousTrack) }
    func play() { MRSentCommand(.play) }
    func pause() { MRSentCommand(.pause) }

    func seek(to seconds: Double) {
        MRSeek(to: seconds)
        position = seconds
    }
}
