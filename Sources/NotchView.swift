import SwiftUI

struct NotchView: View {
    @StateObject private var np = NowPlayingService.shared
    @State private var hovering = false

    var body: some View {
        ZStack {
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
                        MarqueeText(text: np.title.isEmpty ? "Nothing playing" : np.title,
                                    font: .system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                    HStack {
                        Text(formatTime(np.position))
                        Spacer()
                        Text(formatTime(np.duration))
                    }
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
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
            .offset(y: hovering ? 0 : -60)
            .opacity(hovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: hovering)
        }
        .frame(width: 380, height: 60)
        .onHover { hovering = $0 }
    }

    private var progress: Double { guard np.duration > 0 else { return 0 }; return min(1, max(0, np.position / np.duration)) }

    private func appIcon(bundleID: String) -> NSImage? {
        guard !bundleID.isEmpty, let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
    private func formatTime(_ time: Double) -> String {
        guard time.isFinite && !time.isNaN else { return "--:--" }
        let total = Int(time)
        let mins = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", mins, secs)
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

struct MarqueeText: View {
    let text: String
    let font: Font
    var speed: Double = 30

    @State private var textWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            ZStack(alignment: .leading) {
                if textWidth > containerWidth {
                    HStack(spacing: 0) {
                        Text(text).font(font)
                        Text(text).font(font)
                    }
                    .offset(x: offset)
                    .onAppear {
                        let distance = textWidth
                        let duration = Double(distance) / speed
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            offset = -distance
                        }
                    }
                } else {
                    Text(text).font(font)
                }
            }
            .lineLimit(1)
            .background(
                Text(text).font(font).lineLimit(1)
                    .background(GeometryReader { inner -> Color in
                        DispatchQueue.main.async { textWidth = inner.size.width }
                        return Color.clear
                    })
                    .hidden()
            )
            .frame(width: containerWidth, alignment: .leading)
            .clipped()
            .onChange(of: text) { _ in
                offset = 0
                DispatchQueue.main.async {
                    if textWidth > containerWidth {
                        let distance = textWidth
                        let duration = Double(distance) / speed
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            offset = -distance
                        }
                    }
                }
            }
        }
    }
}
