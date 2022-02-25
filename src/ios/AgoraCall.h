#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import <Cordova/CDV.h>
#import "AgoraCallManager.h"
#import "AgoraViewController.h"

@interface AgoraCall : CDVPlugin<AgoraRtcEngineDelegate>

@property (nonatomic, strong) NSString *listenerCallbackID;

+ (instancetype)shareInstance;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)join:(CDVInvokedUrlCommand*)command;
- (void)logPluginMessage:(NSString*)message;

@end
