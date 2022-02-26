#import "AgoraCall.h"

@implementation AgoraCall

+ (instancetype)shareInstance {
    static AgoraCall *shareInstance = nil;
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
    return [AgoraCall shareInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)init:(CDVInvokedUrlCommand*)command {
    NSString* appId = [command.arguments objectAtIndex:0];
    
    [[AgoraCallManager shareInstance] init:appId];

    [self setListenerCallbackID:command.callbackId];
    
    [self logPluginMessage:@"ENGINE_CREATED"];
}

- (void)join:(CDVInvokedUrlCommand*)command {
    NSString* accessToken = [command.arguments objectAtIndex:0];
    NSString* channelName = [command.arguments objectAtIndex:1];
    NSString* uid = [command.arguments objectAtIndex:2];
    NSString* channelType = [command.arguments objectAtIndex:3];
    
    if([channelType length] == 0) {
        channelType = @"voice";
    }
    
    [[AgoraCallManager shareInstance] setAccessToken:accessToken];
    [[AgoraCallManager shareInstance] setChannelName:channelName];
    [[AgoraCallManager shareInstance] setUserId:uid];
    [[AgoraCallManager shareInstance] setChannelType:channelType];

    if([channelType isEqualToString:@"video"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AgoraCall" bundle:nil];
        AgoraViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AgoraViewController"];
        [self.viewController presentViewController:vc animated:YES completion:nil];
    } else {
        [[AgoraCallManager shareInstance] joinChannel];
    }
    
    [self logPluginMessage:@"JOIN"];
}

- (void)leave:(CDVInvokedUrlCommand*)command {
    [[AgoraCallManager shareInstance] leaveFromChannel];
    [self logPluginMessage:@"LEAVE"];
}

- (void)switchAudio:(CDVInvokedUrlCommand*)command {
    NSNumber *status = [command.arguments objectAtIndex:0];

    if ([status isEqual: @(YES)]){
        [[AgoraCallManager shareInstance] muteMic];
    } else {
        [[AgoraCallManager shareInstance] unmuteMic];
    }

    [self logPluginMessage:@"SWITCH_AUDIO"];
}

- (void)switchSpeaker:(CDVInvokedUrlCommand*)command {
    NSNumber *status = [command.arguments objectAtIndex:0];

    if ([status isEqual: @(YES)]){
        [[AgoraCallManager shareInstance] enableSpeakerphone];
    } else {
        [[AgoraCallManager shareInstance] disableSpeakerphone];
    }
    
    [self logPluginMessage:@"SWITCH_SPEAKER"];
}

- (void)logPluginMessage:(NSString*)message {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:[self listenerCallbackID]];
}


@end
