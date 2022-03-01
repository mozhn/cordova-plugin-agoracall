#import "AgoraViewController.h"

@implementation AgoraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self joinChannel];
    
    [self.leaveButton setBackgroundImage:[UIImage imageNamed:@"btn_endcall_normal.png"] forState:UIControlStateNormal];
    [self.leaveButton setBackgroundImage:[UIImage imageNamed:@"btn_endcall_pressed.png"] forState:UIControlStateHighlighted];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.remoteView.frame = self.view.bounds;
    self.localView.frame = CGRectMake(self.view.bounds.size.width - 110, 30, 100, 170);
}

- (void)joinChannel {
    self.isMicActive = YES;
    
    self.isCamActive = YES;
    
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

- (IBAction)leaveButtonClick:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cameraToggleButtonClick:(UIButton *)sender {
    if (self.isCamActive) {
        [[AgoraCallManager  shareInstance] disableCam];
        for (UIView *view in [self.localView subviews])
        {
            [view removeFromSuperview];
        }
        [self.camButton setBackgroundImage:[UIImage imageNamed:@"btn_switch_camera_normal.png"] forState:UIControlStateNormal];
        self.isCamActive = NO;
    } else {
        [[AgoraCallManager shareInstance] enableCam];
        [self.camButton setBackgroundImage:[UIImage imageNamed:@"btn_switch_camera_pressed.png"] forState:UIControlStateNormal];
        self.isCamActive = YES;
    }
}
- (IBAction)microphoneToggleButtonClick:(UIButton *)sender {
    if (self.isMicActive) {
        [[AgoraCallManager shareInstance] muteMic];
        [self.micButton setBackgroundImage:[UIImage imageNamed:@"btn_mute_normal.png"] forState:UIControlStateNormal];
        self.isMicActive = NO;
    } else {
        [[AgoraCallManager shareInstance] unmuteMic];
        [self.micButton setBackgroundImage:[UIImage imageNamed:@"btn_unmute_normal.png"] forState:UIControlStateNormal];
        self.isMicActive = YES;
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self leaveChannel];
}
@end
