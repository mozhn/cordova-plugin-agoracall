#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import <Cordova/CDV.h>
#import "AgoraCallManager.h"

@interface AgoraCallPlugin : CDVPlugin<AgoraRtcEngineDelegate>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;  //silinecek
@property (nonatomic, strong) NSString *listenerCallbackID;

+ (id)getInstance;
- (void)startAgoraCall:(CDVInvokedUrlCommand*)command;
@end
