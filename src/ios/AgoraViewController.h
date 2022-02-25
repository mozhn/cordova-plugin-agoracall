#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "AgoraCall.h"

@interface AgoraViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UIButton *camButton;
@property (nonatomic, assign) BOOL isMicActive;
@property (nonatomic, assign) BOOL isCamActive;

- (void)requestRequiredPermissions;
@end
