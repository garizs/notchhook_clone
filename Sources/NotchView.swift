import SwiftUI

struct NotchView: View {
    @StateObject private var np = NowPlayingService.shared
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 10) {
            ArtworkView(image: np.artworkImage)
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.white.opacity(0.08)))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if let appIcon = appIcon(bundleID: np.appBundleID) {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 14, height: 14)
                            .cornerRadius(3)
                            .opacity(0.9)
                    }
                    Text(np.title.isEmpty ? "Nothing playing" : np.title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                }
                Text(np.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ProgressBar(progress: progress)
                    .frame(height: 3)
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        guard np.duration > 0 else { return }
                        let pct = min(max(0, value.location.x / 240), 1)
                        np.seek(to: Double(pct) * np.duration)
                    })
            }
            .frame(width: 240)

            if hovering {
                HStack(spacing: 8) {
                    Button(action: { np.previousTrack() }) { Image(systemName: "backward.fill") }
                    Button(action: { np.togglePlayPause() }) { Image(systemName: np.isPlaying ? "pause.fill" : "play.fill") }
                    Button(action: { np.nextTrack() }) { Image(systemName: "forward.fill") }
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.08)))
        .onHover { hovering = $0 }
        .animation(.easeInOut(duration: 0.2), value: hovering)
        .frame(minWidth: 380)
    }

    private var progress: Double { guard np.duration > 0 else { return 0 }; return min(1, max(0, np.position / np.duration)) }

    private func appIcon(bundleID: String) -> NSImage? {
        guard !bundleID.isEmpty, let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}

struct ArtworkView: View {
    let image: NSImage?
    var body: some View {
        Group {
            if let img = image { Image(nsImage: img).resizable().scaledToFill() }
            else { ZStack { Rectangle().fill(.gray.opacity(0.15)); Image(systemName: "music.note").font(.system(size: 14)).opacity(0.6) } }
        }
    }
}

struct ProgressBar: View {
    var progress: Double
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(.white.opacity(0.08))
            Capsule().frame(width: nil).overlay(GeometryReader { geo in
                Capsule().fill(.white.opacity(0.7)).frame(width: geo.size.width * progress)
            })
        }
    }
}
