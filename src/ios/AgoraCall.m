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

    [[AgoraCall shareInstance] setListenerCallbackID:command.callbackId];
    
    [[AgoraCall shareInstance] logPluginMessage:@"ENGINE_CREATED"];
}

- (void)join:(CDVInvokedUrlCommand*)command {
    NSString* accessToken = [command.arguments objectAtIndex:0];
    NSString* channelName = [command.arguments objectAtIndex:1];
    NSString* uid = [command.arguments objectAtIndex:2];
    NSString* channelType = [command.arguments objectAtIndex:3];
    
    [[AgoraCallManager shareInstance] setAccessToken:accessToken];
    [[AgoraCallManager shareInstance] setChannelName:channelName];
    [[AgoraCallManager shareInstance] setUserId:uid];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AgoraCall" bundle:nil];
    AgoraViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AgoraViewController"];
    [self.viewController presentViewController:vc animated:YES completion:nil];

    [self logPluginMessage:@"JOIN"];
}

- (void)logPluginMessage:(NSString*)message {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:[[AgoraCall shareInstance] listenerCallbackID]];
    NSLog(@"logPluginMessage listener callback id: %@, message: %@", [[AgoraCall shareInstance] listenerCallbackID], message);
}


@end
