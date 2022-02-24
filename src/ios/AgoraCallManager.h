#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "AgoraViewController.h"
#import "AgoraCall.h"

@interface AgoraCallManager : NSObject<AgoraRtcEngineDelegate>

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;

@property (nonatomic, weak) NSString *token;
- (void)setToken:(NSString*)token;
- (NSString*)getToken;
@property (nonatomic, strong) NSString *channelName;
- (void)setChannelName:(NSString*)channelName;
- (NSString*)getChannelName;
@property (nonatomic, strong) NSString *userId;
- (void)setUserId:(NSString*)userId;
- (NSString*)getUserId;


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
