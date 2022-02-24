#import "AgoraCallPlugin.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@implementation AgoraCallPlugin


+ (id)getInstance {
    static AgoraCallPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startAgoraCall:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    /*
    NSString* accessToken = [command.arguments objectAtIndex:0];
    NSString* channelName = [command.arguments objectAtIndex:1];
    NSString* uid = [command.arguments objectAtIndex:2];
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AgoraCall" bundle:nil];
    AgoraViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AgoraViewController"];
    [self.viewController presentViewController:vc animated:YES completion:nil ];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
