#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "AgoraViewController.h"
#import "AgoraCall.h"

@interface AgoraCallManager : NSObject<AgoraRtcEngineDelegate>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *userId;


+ (id)getInstance;
- (void)init:(NSString*)appId;
- (void)joinChannel;
- (void)leaveFromChannel;
- (void)muteMic;
- (void)unmuteMic;
- (void)enableCam;
- (void)disableCam;
- (void)setLocalVideoCanvas:(AgoraRtcVideoCanvas*)canvas;
- (void)setRemoteVideoCanvas:(AgoraRtcVideoCanvas*)canvas;

@end
