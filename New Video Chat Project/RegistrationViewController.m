//
//  ViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/13/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#import <SinchVerification/SinchVerification.h>
#import "RegistrationViewController.h"
#import "VerifyCodeViewController.h"
#import "POP.h"

#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import "AppDelegate.h"
#import "IntroToProfileViewController.h"
#import "EnterUsername.h"
#import "SVProgressHUD.h"



@interface RegistrationViewController ()
{
    id<SINVerification> _verification;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) id<SINVerification> verification;
@property NSString *myUserId;
@property AppDelegate *appDelegate;
@end

@implementation RegistrationViewController




-(void)viewWillAppear:(BOOL)animated {

    // UI Fade In Animation initial state -

    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.requestCodeButton.alpha = 0;
        self.phoneNumberIcon.alpha = 0;
    } completion:nil];

    [UIView animateWithDuration:7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    } completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // UI Fade In Animation final state -

    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.requestCodeButton.alpha = 1.0;
        self.phoneNumberIcon.alpha = 1.0;

        [UIView animateWithDuration:8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        } completion:nil];

    } completion:nil];

    //    self.myUserId = [NSString stringWithFormat:@"%@",[[PFUser currentUser]valueForKey:@"username"]];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self restrictRotation:YES];

    // ScrollView -

    self.imageView.image = [UIImage imageNamed:@"image.png"];

    [UIView animateWithDuration:50.0f delay:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.scrollView.contentOffset = CGPointMake(250, 0);
    } completion:NULL];

    [UIView animateWithDuration:50.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(-250, 0);
    } completion:NULL];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    // Custom Textfield -

    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 0.8;
    border.borderColor = [UIColor colorWithRed:217
                                         green:221
                                          blue:222
                                         alpha:1.0].CGColor;
    border.frame = CGRectMake(1, self.phoneNumber.frame.size.height - borderWidth, self.phoneNumber.frame.size.width, self.phoneNumber.frame.size.height);
    border.borderWidth = borderWidth;
    [self.phoneNumber.layer addSublayer:border];
    self.phoneNumber.layer.masksToBounds = YES;
    border.cornerRadius = 5;

    CALayer *areaCodeBorder = [CALayer layer];
    CGFloat borderWidth1 = 1.2;
    areaCodeBorder.borderColor = [UIColor whiteColor].CGColor;
    areaCodeBorder.frame = CGRectMake(0, self.areaCode.frame.size.height - borderWidth, self.areaCode.frame.size.width, self.areaCode.frame.size.height);
    areaCodeBorder.borderWidth = borderWidth1;
    [self.areaCode.layer addSublayer:areaCodeBorder];
    self.areaCode.layer.masksToBounds = YES;
    areaCodeBorder.cornerRadius = 5;


    // Custom request button -

    self.requestCodeButton.layer.cornerRadius = 26;
    self.requestCodeButton.layer.masksToBounds = YES;

    // Custom scrolview settings -

    self.scrollView.frame = self.view.bounds;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.contentSize = self.imageView.bounds.size;
    self.scrollView.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;


}

-(void) restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

#pragma mark - user interaction -

- (IBAction)requestCode:(id)sender {

    {
        [SVProgressHUD showWithStatus:@"Requesting"];

        NSNumber *number = @([self.phoneNumber.text doubleValue]);

        self.phoneDigits = number;

        self.requestCodeButton.enabled = NO;

        if ([_phoneNumber.text isEqualToString:@""])
        {
            [SVProgressHUD showInfoWithStatus:@"You must enter a phonenumber"];

            // Animate Request code button if textfield is empty
            [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:10.0 options:nil animations:^{
                self.requestCodeButton.bounds = CGRectMake(self.requestCodeButton.bounds.origin.x - 40, self.requestCodeButton.bounds.origin.y, self.requestCodeButton.bounds.size.width + 60, self.requestCodeButton.bounds.size.height);
                self.requestCodeButton.enabled = true ;
            } completion:nil];
            return;
        }

        //start the verification process with the phonenumber in the field
        _verification = [SINVerification SMSVerificationWithApplicationKey:@"bb3898a8-951f-4a43-b857-a66b4546778e" phoneNumber:_phoneNumber.text];

        //set up a initiate the process
        [_verification initiateWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [SVProgressHUD showWithStatus:@"Success"];
                [SVProgressHUD dismiss];
                self.requestCodeButton.enabled = true ;

                VerifyCodeViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customModal"];
                modalVC.transitioningDelegate = self;
                modalVC.modalPresentationStyle = UIModalPresentationCustom;
                modalVC.verification = self.verification;
                modalVC.phoneDigits = self.phoneDigits;

                [self.navigationController presentViewController:modalVC animated:YES completion:nil];

            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"Please enter a valid number"];

                self.requestCodeButton.enabled = YES;

                // Animate Request code button if thers is an error
                [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:10 options:nil animations:^{
                    self.requestCodeButton.bounds = CGRectMake(self.requestCodeButton.bounds.origin.x - 40, self.requestCodeButton.bounds.origin.y, self.requestCodeButton.bounds.size.width + 60, self.requestCodeButton.bounds.size.height);
                    self.requestCodeButton.enabled = true ;
                } completion:nil];
            }
        }];


    }
}
// resign first responder if touch outside the textfields
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.areaCode isFirstResponder] && [touch view] != self.areaCode)
        [self.areaCode resignFirstResponder];
    ([self.phoneNumber isFirstResponder] && [touch view] != self.phoneNumber); {
        [self.phoneNumber    resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Segue's -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"customModal"]){
        VerifyCodeViewController* vc = [segue destinationViewController];
        vc.verification = _verification;
        vc.phoneDigits = self.phoneDigits;
    } else if ([segue.identifier isEqualToString:@"alreadyauserSeg"]){
        IntroToProfileViewController *IntroVC = [segue destinationViewController];
        IntroVC.myUserId = self.myUserId;
    }
}

- (IBAction)alreadyUserOnPress:(id)sender {

    EnterUsername *EnterUsernameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"customModal2"];
    EnterUsernameVC.transitioningDelegate = self;
    EnterUsernameVC.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:EnterUsernameVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitionDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

@end
