#import "AgoraCallManager.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@implementation AgoraCallManager

+ (id)getInstance {
    static AgoraCallManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)init:(NSString*)appId {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:self];
}

- (void)joinChannel:(NSString*)token channelName:(NSString*)channelName uid:(NSString*)uid{
    [self.agoraKit enableAudio];
    [self.agoraKit enableVideo];
    [self.agoraKit enableLocalAudio:true];
    [self.agoraKit enableLocalVideo:true];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [AgoraRtcChannelMediaOptions new];
    mediaOptions.autoSubscribeAudio = true;
    mediaOptions.autoSubscribeVideo = true;
    
    [self.agoraKit joinChannelByUserAccount:uid token:token channelId:channelName options:mediaOptions];
}

- (void)leaveFromChannel {
    [self.agoraKit disableAudio];
    [self.agoraKit disableVideo];
    [self.agoraKit enableLocalAudio:false];
    [self.agoraKit enableLocalVideo:false];
    
    [self.agoraKit leaveChannel:^(AgoraChannelStats *stat){
        NSLog(@"left from the channel");
    }];
}

- (void)muteMic {
    [self.agoraKit muteLocalAudioStream:YES];
}

- (void)unmuteMic {
    [self.agoraKit muteLocalAudioStream:NO];
}

- (void)enableCam {
    [self.agoraKit muteLocalVideoStream:NO];
    [self.agoraKit enableLocalVideo:true];
}

- (void)disableCam {
    [self.agoraKit muteLocalVideoStream:YES];
    [self.agoraKit enableLocalVideo:false];
}

- (void)setLocalVideoCanvas:(AgoraRtcVideoCanvas*)canvas {
    [self.agoraKit setupLocalVideo:canvas];
}

- (void)setRemoteVideoCanvas:(AgoraRtcVideoCanvas*)canvas {
    [self.agoraKit setupRemoteVideo:canvas];
}

///
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    AgoraViewController *activeAgoraViewController = (AgoraViewController*)[[window rootViewController] presentedViewController];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.view = [activeAgoraViewController remoteView];
    [[AgoraCallManager getInstance] setRemoteVideoCanvas:videoCanvas];
    NSLog(@"PARTICIPANT_CONNECTED");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    NSLog(@"CONNECTED");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRegisteredLocalUser:(NSString *)userAccount withUid:(NSUInteger)uid {
    NSLog(@"USER_REGISTERED");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraChannelStats *)stats {
    NSLog(@"DISCONNECTED");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    AgoraViewController *activeAgoraViewController = (AgoraViewController*)[[window rootViewController] presentedViewController];
    for (UIView *view in [activeAgoraViewController.remoteView subviews])
    {
        [view removeFromSuperview];
    }
    NSLog(@"PARTICIPANT_DISCONNECTED");
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode {
    NSString *code = [NSString stringWithFormat:@"WARNING_CODE_%ld", (long)warningCode];

    NSLog(@"%@", code);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSString *code = [NSString stringWithFormat:@"ERROR_CODE_%ld", (long)errorCode];
    NSLog(@"%@", code);
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine {
    NSLog(@"TOKEN_EXPIRED");
}
@end

