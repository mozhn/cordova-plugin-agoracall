#import <UIKit/UIKit.h>
#import "AgoraViewController.h"

@implementation AgoraViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAgora];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.remoteView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 150);
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
    [[AgoraCallManager getInstance] setLocalVideoCanvas:videoCanvas];
    
    [[AgoraCallManager getInstance] joinChannel:@"006fa0f283dd55447488d68c9be1a0776abIABHYIZkPUWv22YU/E4eCEWH4E1RCg6aTjHBr0zldPKCQUcAdXoAAAAAEABkcFWNkKcYYgEAAQCPpxhi" channelName:@"Kanal1" uid:@"2"];
    NSLog(@"joined");
}

- (void)initAgora {
    [[AgoraCallManager getInstance] init:@"fa0f283dd55447488d68c9be1a0776ab"];
}

- (void)leaveChannel {
    [[AgoraCallManager getInstance] leaveFromChannel];
    
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

- (IBAction)joinButtonClick:(UIButton *)sender {
    [self joinChannel];
}
- (IBAction)leaveButtonClick:(UIButton *)sender {
    [self leaveChannel];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cameraToggleButtonClick:(UIButton *)sender {
    NSLog(@"cameraToggle");
    if (self.isCamActive) {
        [[AgoraCallManager  getInstance] disableCam];
        for (UIView *view in [self.localView subviews])
        {
            [view removeFromSuperview];
        }
        [self.camButton setTitle:@"Cam Disabled" forState:UIControlStateNormal];
        self.isCamActive = NO;
    } else {
        [[AgoraCallManager getInstance] enableCam];
        [self.camButton setTitle:@"Cam Enabled" forState:UIControlStateNormal];
        self.isCamActive = YES;
    }
}
- (IBAction)microphoneToggleButtonClick:(UIButton *)sender {
    NSLog(@"micToggle");
    if (self.isMicActive) {
        [[AgoraCallManager getInstance] muteMic];
        [self.micButton setTitle:@"Mic Muted" forState:UIControlStateNormal];
        self.isMicActive = NO;
    } else {
        [[AgoraCallManager getInstance] unmuteMic];
        [self.micButton setTitle:@"Mic Unmuted" forState:UIControlStateNormal];
        self.isMicActive = YES;
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self leaveChannel];
    [AgoraRtcEngineKit destroy];
}
@end
