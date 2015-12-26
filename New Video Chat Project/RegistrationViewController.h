//
//  ViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/13/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationViewController : UIViewController <UIViewControllerTransitioningDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIButton *requestCodeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property NSNumber *phoneDigits;
@property NSMutableArray *allobjects;
@property (weak, nonatomic) IBOutlet UITextField *areaCode;
@property (weak, nonatomic) IBOutlet UILabel *PleaseEnterLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumberIcon;

- (IBAction)requestCode:(id)sender;

@end

