import Foundation

func MRBridgeGetNowPlayingInfo(_ block: @escaping ([String: Any]) -> Void) {
    MRGetNowPlayingInfo { info in
        var dict: [String: Any] = [:]
        info.forEach { key, value in if let k = key as? String { dict[k] = value } }
        block(dict)
    }
}

func MRBridgeGetIsPlaying(_ block: @escaping (Bool) -> Void) {
    MRGetIsPlaying { playing in block(playing) }
}

func MRSeek(to seconds: Double) {
    MRSeekToTime(seconds)
}
