#import "MediaRemoteBridge.h"
#import <dlfcn.h>

static void *MRHandle;

__attribute__((constructor))
static void _LoadMR(void) {
    MRHandle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY);
}

void MRRegisterForNowPlayingNotifications(void) {
    if (!MRHandle) return;
    void (*fn)(dispatch_queue_t) = dlsym(MRHandle, "MRMediaRemoteRegisterForNowPlayingNotifications");
    if (fn) fn(dispatch_get_main_queue());
}

void MRUnregisterForNowPlayingNotifications(void) {
    if (!MRHandle) return;
    void (*fn)(void) = dlsym(MRHandle, "MRMediaRemoteUnregisterForNowPlayingNotifications");
    if (fn) fn();
}

void MRGetNowPlayingInfo(void (^block)(NSDictionary *)) {
    if (!MRHandle) { if (block) block(@{}); return; }
    void (*fn)(dispatch_queue_t, void (^)(CFDictionaryRef)) = dlsym(MRHandle, "MRMediaRemoteGetNowPlayingInfo");
    if (!fn) { if (block) block(@{}); return; }
    fn(dispatch_get_main_queue(), ^(CFDictionaryRef info){
        NSDictionary *dict = (__bridge NSDictionary *)info;
        if (block) block(dict ?: @{});
    });
}

void MRGetIsPlaying(void (^block)(BOOL)) {
    if (!MRHandle) { if (block) block(NO); return; }
    void (*fn)(dispatch_queue_t, void (^block)(Boolean)) = dlsym(MRHandle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying");
    if (!fn) { if (block) block(NO); return; }
    fn(dispatch_get_main_queue(), ^(Boolean playing){ if (block) block(playing); });
}

void MRSentCommand(MRCommand command) {
    if (!MRHandle) return;
    Boolean (*fn)(MRCommand, CFDictionaryRef) = dlsym(MRHandle, "MRMediaRemoteSendCommand");
    if (fn) (void)fn(command, NULL);
}

void MRSeekToTime(NSTimeInterval seconds) {
    if (!MRHandle) return;
    Boolean (*fn)(MRCommand, CFDictionaryRef) = dlsym(MRHandle, "MRMediaRemoteSendCommand");
    if (!fn) return;

    // Fetch constant dynamically
    CFStringRef *kMRMediaRemoteOptionPlaybackPositionPtr = dlsym(MRHandle, "kMRMediaRemoteOptionPlaybackPosition");
    if (!kMRMediaRemoteOptionPlaybackPositionPtr) return;
    CFStringRef kMRMediaRemoteOptionPlaybackPosition = *kMRMediaRemoteOptionPlaybackPositionPtr;
    if (!kMRMediaRemoteOptionPlaybackPosition) return;

    NSDictionary *opts = @{ (__bridge NSString*)kMRMediaRemoteOptionPlaybackPosition : @(seconds) };
    (void)fn(MRCommandChangePlaybackPosition, (__bridge CFDictionaryRef)opts);
}

static void MRPostCFNotif(CFStringRef name) {
    NSString *n = (__bridge NSString *)name;
    [[NSNotificationCenter defaultCenter] postNotificationName:n object:nil];
}

static void _MRNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    (void)center;
    (void)observer;
    (void)object;
    (void)userInfo;
    MRPostCFNotif(name);
}

__attribute__((constructor))
static void _SetUpCFObservers(void) {
    if (!MRHandle) return;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    if (!center) return;

    // Fetch notification names dynamically
    CFStringRef *kNowPlayingInfoDidChangePtr = dlsym(MRHandle, "kMRMediaRemoteNowPlayingInfoDidChangeNotification");
    CFStringRef *kIsPlayingDidChangePtr = dlsym(MRHandle, "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification");
    CFStringRef kNowPlayingInfoDidChange = kNowPlayingInfoDidChangePtr ? *kNowPlayingInfoDidChangePtr : NULL;
    CFStringRef kIsPlayingDidChange = kIsPlayingDidChangePtr ? *kIsPlayingDidChangePtr : NULL;

    static int observerToken;

    if (kNowPlayingInfoDidChange) {
        CFNotificationCenterAddObserver(center, &observerToken, _MRNotificationCallback,
                                       kNowPlayingInfoDidChange, NULL,
                                       CFNotificationSuspensionBehaviorDeliverImmediately);
    }

    if (kIsPlayingDidChange) {
        CFNotificationCenterAddObserver(center, &observerToken, _MRNotificationCallback,
                                       kIsPlayingDidChange, NULL,
                                       CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
