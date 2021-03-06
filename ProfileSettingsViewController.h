//
//  ProfileSettingsViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)tapGesture:(UITapGestureRecognizer *)tapGestureRecognizer2;
-(void)tapGestureName:(UITapGestureRecognizer *)tapGestureRecognizerForName;

-(void)tapGestureStatus:(UITapGestureRecognizer *)tapGestureRecognizerForStatus;

@end
