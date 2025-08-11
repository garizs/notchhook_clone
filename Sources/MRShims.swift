import Foundation

func MRGetNowPlayingInfo(_ block: @escaping ([String: Any]) -> Void) {
    MRGetNowPlayingInfo { info in
        var dict: [String: Any] = [:]
        info.forEach { key, value in if let k = key as? String { dict[k] = value } }
        block(dict)
    }
}

func MRGetIsPlaying(_ block: @escaping (Bool) -> Void) { MRGetIsPlaying { playing in block(playing) } }

enum MRCommandSwift: Int { case togglePlayPause = 0, play = 1, pause = 2, stop = 3, nextTrack = 4, previousTrack = 5, changePlaybackPosition = 13 }

func MRSentCommand(_ cmd: MRCommandSwift) { MRSentCommand(MRCommand(rawValue: cmd.rawValue)!) }

func MRSeek(to seconds: Double) { MRSeekToTime(seconds) }
