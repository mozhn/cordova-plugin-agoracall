#import "AgoraViewController.h"

@implementation AgoraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self joinChannel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.remoteView.frame = self.view.bounds;
    self.localView.frame = CGRectMake(self.view.bounds.size.width - 90, 0, 90, 160);
}

- (void)joinChannel {
    [self requestRequiredPermissions];
    
    self.isMicActive = YES;
    [self.micButton setTitle:@"Mic Unmuted" forState:UIControlStateNormal];
    
    self.isCamActive = YES;
    [self.camButton setTitle:@"Cam Enabled" forState:UIControlStateNormal];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 2;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.view = self.localView;
    [[AgoraCallManager shareInstance] setLocalVideoCanvas:videoCanvas];
    
    [[AgoraCallManager shareInstance] joinChannel];
}

- (void)leaveChannel {
    [[AgoraCallManager shareInstance] leaveFromChannel];
    
    for (UIView *view in [self.remoteView subviews])
    {
        [view removeFromSuperview];
    }
    for (UIView *view in [self.localView subviews])
    {
        [view removeFromSuperview];
    }
}

- (void)requestRequiredPermissions {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL grantedCamera)
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL grantedAudio) {
            NSLog(@"mic and cam access done");
        }];
    }];
}

- (IBAction)leaveButtonClick:(UIButton *)sender {
    [self leaveChannel];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cameraToggleButtonClick:(UIButton *)sender {
    NSLog(@"cameraToggle");
    if (self.isCamActive) {
        [[AgoraCallManager  shareInstance] disableCam];
        for (UIView *view in [self.localView subviews])
        {
            [view removeFromSuperview];
        }
        [self.camButton setTitle:@"Cam Disabled" forState:UIControlStateNormal];
        self.isCamActive = NO;
    } else {
        [[AgoraCallManager shareInstance] enableCam];
        [self.camButton setTitle:@"Cam Enabled" forState:UIControlStateNormal];
        self.isCamActive = YES;
    }
}
- (IBAction)microphoneToggleButtonClick:(UIButton *)sender {
    NSLog(@"micToggle");
    if (self.isMicActive) {
        [[AgoraCallManager shareInstance] muteMic];
        [self.micButton setTitle:@"Mic Muted" forState:UIControlStateNormal];
        self.isMicActive = NO;
    } else {
        [[AgoraCallManager shareInstance] unmuteMic];
        [self.micButton setTitle:@"Mic Unmuted" forState:UIControlStateNormal];
        self.isMicActive = YES;
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self leaveChannel];
}
@end
