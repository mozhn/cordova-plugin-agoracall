#import <Cordova/CDV.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>


@interface AgoraCall : CDVPlugin<AgoraRtcEngineDelegate> {}

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) NSString *listenerCallbackID;

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)join:(CDVInvokedUrlCommand*)command;
- (void)leave:(CDVInvokedUrlCommand*)command;
- (void)switchAudio:(CDVInvokedUrlCommand*)command;
- (void)switchSpeaker:(CDVInvokedUrlCommand*)command;
@end

@implementation AgoraCall

- (void)init:(CDVInvokedUrlCommand*)command
{
    self.listenerCallbackID = command.callbackId;
    NSString* appId = [command.arguments objectAtIndex:0];

    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:self];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"ENGINE_CREATED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)join:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* accessToken = [command.arguments objectAtIndex:0];
    NSString* channelName = [command.arguments objectAtIndex:1];
    NSString* uid = [command.arguments objectAtIndex:2];

    AgoraRtcChannelMediaOptions *mediaOptions = nil;
    mediaOptions.autoSubscribeAudio = true;
    mediaOptions.autoSubscribeVideo = false;

    [self.agoraKit joinChannelByUserAccount:uid token:accessToken channelId:channelName options:mediaOptions];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)leave:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    [self.agoraKit leaveChannel:nil];
    [AgoraRtcEngineKit destroy];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)switchAudio:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    BOOL status = [command.arguments objectAtIndex:0];

    [self.agoraKit muteLocalAudioStream:status];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)switchSpeaker:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    BOOL status = [command.arguments objectAtIndex:0];

    [self.agoraKit setEnableSpeakerphone:status];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"CONNECTED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRegisteredLocalUser:(NSString *)userAccount withUid:(NSUInteger)uid {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"USER_REGISTERED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraChannelStats *)stats {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"DISCONNECTED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"PARTICIPANT_CONNECTED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"PARTICIPANT_DISCONNECTED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode {
    NSString *code = [NSString stringWithFormat:@"WARNING_CODE_%ld", (long)warningCode];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:code];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSString *code = [NSString stringWithFormat:@"ERROR_CODE_%ld", (long)errorCode];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:code];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@"TOKEN_EXPIRED"];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

@end
