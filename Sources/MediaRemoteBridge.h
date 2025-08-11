#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

extern CFStringRef kMRMediaRemoteNowPlayingInfoDidChangeNotification;
extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;

extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
extern CFStringRef kMRMediaRemoteNowPlayingInfoElapsedTime;
extern CFStringRef kMRMediaRemoteNowPlayingInfoDuration;
extern CFStringRef kMRMediaRemoteNowPlayingInfoClientBundleIdentifier;

extern CFStringRef kMRMediaRemoteOptionPlaybackPosition;

typedef NS_ENUM(NSInteger, MRCommand) {
    MRCommandTogglePlayPause = 0,
    MRCommandPlay = 1,
    MRCommandPause = 2,
    MRCommandStop = 3,
    MRCommandNextTrack = 4,
    MRCommandPreviousTrack = 5,
    MRCommandChangePlaybackPosition = 13,
};

void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
void MRMediaRemoteUnregisterForNowPlayingNotifications(void);
void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, void (^block)(CFDictionaryRef info));
void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, void (^block)(Boolean playing));
Boolean MRMediaRemoteSendCommand(MRCommand command, CFDictionaryRef options);

#ifdef __cplusplus
}
#endif

FOUNDATION_EXPORT void MRRegisterForNowPlayingNotifications(void);
FOUNDATION_EXPORT void MRUnregisterForNowPlayingNotifications(void);
FOUNDATION_EXPORT void MRGetNowPlayingInfo(void (^block)(NSDictionary *info));
FOUNDATION_EXPORT void MRGetIsPlaying(void (^block)(BOOL playing));
FOUNDATION_EXPORT void MRSentCommand(MRCommand command);
FOUNDATION_EXPORT void MRSeekToTime(NSTimeInterval seconds);
