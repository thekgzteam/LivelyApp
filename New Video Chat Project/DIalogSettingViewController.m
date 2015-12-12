//
//  DIalogSettingViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 12/6/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "DIalogSettingViewController.h"
#import "QCMethod.h"
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>

@interface DIalogSettingViewController () <QBChatDelegate,QBRTCClientDelegate>
@property BOOL speakersAreOn;
@end

@implementation DIalogSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[AVAudioSession sharedInstance] setDelegate:self];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    self.view.layer.cornerRadius = 8.f;
    self.dissmisButton.layer.cornerRadius = 15.0f;
    self.muteButton.layer.cornerRadius = 5.f;
    self.loudspeakerOff.layer.cornerRadius = 5.f;
    self.videoOffButton.layer.cornerRadius = 5.f;
    [self.muteButton.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
    [self.loudspeakerOff.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
    [self.videoOffButton.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.view.frame = CGRectMake(100, 155, 160.f, 340.f);
}

- (IBAction)onDismissButtonPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark UI ANIMATION METHODS
- (CAAnimationGroup*)imageAnimation{

    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.37;

    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];;
    transformAnim.duration           = 0.188;
    transformAnim.autoreverses       = YES;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    CAAnimationGroup *imageAnimGroup   = [CAAnimationGroup animation];
    imageAnimGroup.animations          = @[opacityAnim, transformAnim];
    [imageAnimGroup.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
    imageAnimGroup.fillMode            = kCAFillModeForwards;
    imageAnimGroup.removedOnCompletion = NO;
    imageAnimGroup.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup.animations];

    return imageAnimGroup;
}

- (IBAction)enableLoudSpeakers:(id)sender {
    if (self.loudspeakerOff.selected) {
        [self enableSpeakers];
        self.videoOffButton.selected = YES;
        [self.loudspeakerOff setImage:[UIImage imageNamed:@"loudspeaker"] forState:UIControlStateSelected];
//            [self.loudspeakerOff setBackgroundColor:[UIColor colorWithRed:236.0f green:236.0f blue:236.0f alpha:0.3]];


    } else
        [self disableSpeakers];

    [self.loudspeakerOff setImage:[UIImage imageNamed:@"loudspeakeroff"] forState:UIControlStateSelected];

    self.loudspeakerOff.selected = !self.loudspeakerOff.selected;
//    [self.loudspeakerOff setBackgroundColor:[UIColor colorWithRed:34.0f green:49.0f blue:63.0f alpha:0.3]];



}

- (IBAction)videoButton:(id)sender {



}

-(void)enableSpeakers {

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;

    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
}

-(void)disableSpeakers {

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;

    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
}


@end
