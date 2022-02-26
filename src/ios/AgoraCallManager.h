#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "AgoraViewController.h"
#import "AgoraCall.h"

@interface AgoraCallManager : NSObject<AgoraRtcEngineDelegate>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *channelType;


+ (instancetype)shareInstance;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (void)init:(NSString*)appId;
- (void)joinChannel;
- (void)leaveFromChannel;
- (void)muteMic;
- (void)unmuteMic;
- (void)enableCam;
- (void)disableCam;
- (void)enableSpeakerphone;
- (void)disableSpeakerphone;
- (void)setLocalVideoCanvas:(AgoraRtcVideoCanvas*)canvas;
- (void)setRemoteVideoCanvas:(AgoraRtcVideoCanvas*)canvas;
- (void)requestRequiredPermissions;

@end
