//
//  VerifyCodeViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/14/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RegistrationViewController.h"

@interface VerifyCodeViewController : UIViewController <UIViewControllerTransitioningDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property id<SINVerification> verification;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property NSNumber *phoneDigits;
@property UIImageView *imageView;
- (IBAction)verifyCode:(id)sender;

@end
