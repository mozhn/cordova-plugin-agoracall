#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import <Cordova/CDV.h>
#import "AgoraCallManager.h"

@interface AgoraCall : CDVPlugin<AgoraRtcEngineDelegate>

@property (nonatomic, strong) NSString *listenerCallbackID;

+ (id)getInstance;
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)join:(CDVInvokedUrlCommand*)command;
@end
