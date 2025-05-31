#import "AgoraViewController.h"

@implementation AgoraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self joinChannel];
    
    [self.leaveButton setBackgroundImage:[UIImage imageNamed:@"btn_endcall_normal.png"] forState:UIControlStateNormal];
    [self.leaveButton setBackgroundImage:[UIImage imageNamed:@"btn_endcall_pressed.png"] forState:UIControlStateHighlighted];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
  //[self testLocalPreview];
   [self startLocalPreviewAndJoin];
}

- (void)testLocalPreview {
    // 1) Engine’in initialize edildiğinden emin olun
    AgoraCallManager *mgr = [AgoraCallManager shareInstance];
    if (!mgr.agoraKit) {
        NSLog(@"⚠️ Agora engine henüz init edilmemiş!");
        return;
    }

    // 2) İzinleri kontrol edin (asenkron). İzin verildiyse devam:
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL grantedCamera) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL grantedAudio) {
            if (!grantedCamera || !grantedAudio) {
                NSLog(@"⚠️ Kamera ya da mikrofon izni yok!");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // 3) Video motorunu açın
                [mgr.agoraKit enableVideo];
                [mgr.agoraKit enableLocalVideo:YES];

                // 4) Local canvas oluşturun
                AgoraRtcVideoCanvas *localCanvas = [[AgoraRtcVideoCanvas alloc] init];
                localCanvas.uid = 0; // 0 dersek sunucu bir UID atayacak, preview için yeterli
                localCanvas.renderMode = AgoraVideoRenderModeHidden;
                localCanvas.view = self.localView;

                // 5) Canvas ayarlamasını yapın
                [mgr.agoraKit setupLocalVideo:localCanvas];

                // 6) Preview’ı başlatın
                [mgr.agoraKit startPreview];

                // Aşağıdaki log, preview başlatıldığında geçmeli:
                NSLog(@"✅ startPreview çağrıldı – local önizleme başlamalı");
            });
        }];
    }];
}


- (void)startLocalPreviewAndJoin {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL grantedCamera) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL grantedAudio) {
            if (!grantedCamera || !grantedAudio) {
                NSLog(@"⚠️ Kamera veya mikrofon izni reddedildi");
                return;
            }
            // İzinler alındıktan sonra preview ve join işlemini main queue’da yapın
            dispatch_async(dispatch_get_main_queue(), ^{
                // 2) Local video canvas’ı ayarlayın
                AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
                videoCanvas.uid = [[AgoraCallManager shareInstance].userId integerValue];
                videoCanvas.renderMode = AgoraVideoRenderModeHidden;
                videoCanvas.view = self.localView;
                [[AgoraCallManager shareInstance] setLocalVideoCanvas:videoCanvas];
                
                // 3) Agora’dan preview’ı başlatmasını isteyin
                [[AgoraCallManager shareInstance].agoraKit startPreview];
                
                // 4) Agora’ya gerçek join isteğini yapın
                [[AgoraCallManager shareInstance] joinChannel];
            });
        }];
    }];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.remoteView.frame = self.view.bounds;
    self.localView.frame = CGRectMake(self.view.bounds.size.width - 110, 30, 100, 170);
}

- (void)joinChannel {
  self.isMicActive = YES;
  self.isCamActive = YES;
  
  [[AgoraCallManager shareInstance] joinChannel];

}

- (void)leaveChannel {
  [[AgoraCallManager shareInstance] leaveFromChannel];
  
  for (UIView *view in [self.remoteView subviews]) {
      [view removeFromSuperview];
  }
  for (UIView *view in [self.localView subviews]) {
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
        [self.camButton setBackgroundImage:[UIImage imageNamed:@"btn_camera_toggle_pressed.png"] forState:UIControlStateNormal];
        self.isCamActive = NO;
    } else {
        [[AgoraCallManager shareInstance] enableCam];
        [self.camButton setBackgroundImage:[UIImage imageNamed:@"btn_camera_toggle_normal.png"] forState:UIControlStateNormal];
        self.isCamActive = YES;
    }
}
- (IBAction)camSwitchButtonClick:(UIButton *)sender {
    if (self.isFrontCamActive) {
        [[AgoraCallManager shareInstance] switchCam];
        [self.camSwitchButton setBackgroundImage:[UIImage imageNamed:@"btn_switch_camera_pressed.png"] forState:UIControlStateNormal];
        self.isFrontCamActive = NO;
    } else {
        [[AgoraCallManager shareInstance] switchCam];
        [self.camSwitchButton setBackgroundImage:[UIImage imageNamed:@"btn_switch_camera_normal.png"] forState:UIControlStateNormal];
        self.isFrontCamActive = YES;
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
