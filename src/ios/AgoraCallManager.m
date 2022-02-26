#import "AgoraCallManager.h"

@implementation AgoraCallManager

@synthesize accessToken;
@synthesize channelName;
@synthesize userId;

+ (instancetype)shareInstance {
    static AgoraCallManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[super allocWithZone:NULL] initPrivate];
    });
    return shareInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [AgoraCallManager shareInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)init:(NSString*)appId {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:self];
}

- (void)joinChannel {
    [self.agoraKit enableAudio];
    [self.agoraKit enableVideo];
    [self.agoraKit enableLocalAudio:true];
    [self.agoraKit enableLocalVideo:true];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [AgoraRtcChannelMediaOptions new];
    mediaOptions.autoSubscribeAudio = true;
    mediaOptions.autoSubscribeVideo = true;
    
    [self.agoraKit
        joinChannelByUserAccount:self.userId
        token:self.accessToken
     	channelId:self.channelName
        options:mediaOptions];
}

- (void)leaveFromChannel {
    [self.agoraKit disableAudio];
    [self.agoraKit disableVideo];
    [self.agoraKit enableLocalAudio:false];
    [self.agoraKit enableLocalVideo:false];
    
    [self.agoraKit leaveChannel:^(AgoraChannelStats *stat){
        [[AgoraCall shareInstance] logPluginMessage:@"DISCONNECTED"];
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
    [[AgoraCallManager shareInstance] setRemoteVideoCanvas:videoCanvas];
    
    [[AgoraCall shareInstance] logPluginMessage:@"PARTICIPANT_CONNECTED"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    
    [[AgoraCall shareInstance] logPluginMessage:@"CONNECTED"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRegisteredLocalUser:(NSString *)userAccount withUid:(NSUInteger)uid {
    [[AgoraCall shareInstance] logPluginMessage:@"USER_REGISTERED"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraChannelStats *)stats {
    [[AgoraCall shareInstance] logPluginMessage:@"DISCONNECTED"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    AgoraViewController *activeAgoraViewController = (AgoraViewController*)[[window rootViewController] presentedViewController];
    for (UIView *view in [activeAgoraViewController.remoteView subviews])
    {
        [view removeFromSuperview];
    }
    [[AgoraCall shareInstance] logPluginMessage:@"PARTICIPANT_DISCONNECTED"];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode {
    NSString *code = [NSString stringWithFormat:@"WARNING_CODE_%ld", (long)warningCode];

    [[AgoraCall shareInstance] logPluginMessage:code];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSString *code = [NSString stringWithFormat:@"ERROR_CODE_%ld", (long)errorCode];
    [[AgoraCall shareInstance] logPluginMessage:code];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine {
    [[AgoraCall shareInstance] logPluginMessage:@"TOKEN_EXPIRED"];
}


@end

