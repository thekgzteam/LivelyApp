//
//  UserImageVC.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/27/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "UserImageVC.h"

@implementation UserImageVC

-(void)viewDidLoad {
    [super viewDidLoad];
    self.userImage.image = self.imageForUserImage;
    NSLog(@"----------------%@-----------",self.userImage.image);
    NSLog(@"----------------%@-----------",self.imageForUserImage);

    self.view.layer.cornerRadius = 8.0f;
    self.dismissButton.layer.cornerRadius = 14;
}

- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)viewWillAppear:(BOOL)animated {

    [self.userImage.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.dismissButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.userName.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.userStatus.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
}

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.fromValue          = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    transformAnim.duration           = 0.398;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}

- (CABasicAnimation*)ovalAnimationOpacity{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 1;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    return opacityAnim;
}

@end
