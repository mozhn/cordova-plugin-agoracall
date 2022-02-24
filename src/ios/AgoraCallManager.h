#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "AgoraViewController.h"
#import "AgoraCallPlugin.h"

@interface AgoraCallManager : NSObject<AgoraRtcEngineDelegate>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;

+ (id)getInstance;
- (void)init:(NSString*)appId;
- (void)joinChannel:(NSString*)token channelName:(NSString*)channelName uid:(NSString*)uid;
- (void)leaveFromChannel;
- (void)muteMic;
- (void)unmuteMic;
- (void)enableCam;
- (void)disableCam;
- (void)setLocalVideoCanvas:(AgoraRtcVideoCanvas*)canvas;
- (void)setRemoteVideoCanvas:(AgoraRtcVideoCanvas*)canvas;

@end
