#import "AgoraCall.h"

@implementation AgoraCall

+ (id)getInstance {
    static AgoraCall *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)init:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* appId = [command.arguments objectAtIndex:0];
    
    [[AgoraCallManager getInstance] init:appId];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)join:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    
    NSString* accessToken = [command.arguments objectAtIndex:0];
    NSString* channelName = [command.arguments objectAtIndex:1];
    NSString* uid = [command.arguments objectAtIndex:2];
    
    [[AgoraCallManager getInstance] setAccessToken:accessToken];
    [[AgoraCallManager getInstance] setChannelName:channelName];
    [[AgoraCallManager getInstance] setUserId:uid];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AgoraCall" bundle:nil];
    AgoraViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AgoraViewController"];
    [self.viewController presentViewController:vc animated:YES completion:nil ];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
