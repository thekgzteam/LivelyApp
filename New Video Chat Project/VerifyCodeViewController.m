//
//  VerifyCodeViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/14/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//


#import <SinchVerification/SinchVerification.h>
#import "VerifyCodeViewController.h"
#import "POP.h"
#import "IntroToProfileViewController.h"
#import "SVProgressHUD.h"
#import <Quickblox/Quickblox.h>

@interface VerifyCodeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissVIewButton;

@end

@implementation VerifyCodeViewController

@synthesize verification, code, status;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 8.f;
    [self.code.delegate self];
    [SVProgressHUD showInfoWithStatus:@"Please enter a code you will receive"];

    self.imageView.image = [UIImage imageNamed:@"Profile Picture"];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

// resign first responder if touch outside the textfields
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.code isFirstResponder] && [touch view] != self.code)
        [self.code resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    
   self.view.frame = CGRectMake (60,157, 280.f, 370.f);

    // Custom Textfield for entering the received code
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.5;
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, self.code.frame.size.height - borderWidth, self.code.frame.size.width, self.code.frame.size.height);
    border.borderWidth = borderWidth;
    [self.code.layer addSublayer:border];
    self.code.layer.masksToBounds = YES;
    self.verifyButton.layer.cornerRadius = 15;
    self.verifyButton.layer.masksToBounds = YES;
    self.dismissVIewButton.layer.cornerRadius = 15;
    self.dismissVIewButton.layer.masksToBounds = YES;


}

- (void)registerForRemoteNotifications{

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {

        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;

    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {

    } errorBlock:^(QBResponse *response) {
        
    }];
}

#pragma - user interaction -

- (IBAction)verifyCode:(id)sender {
    [self.code resignFirstResponder];
    if ([code.text isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"You must enter a code"];
    }
    [SVProgressHUD showWithStatus:@"Verifying"];
    [self.verification
     verifyCode:code.text
     completionHandler:^(BOOL success, NSError* error) {
         if (success) {
             [SVProgressHUD showSuccessWithStatus:@"Verified"];



             [self.view endEditing:YES];


             QBUUser *user = [QBUUser new];
             user.login = self.phoneDigits;
             user.password = @"samplePassword";
             NSString *password = @"samplePassword";
             NSString *login = self.phoneDigits;


//             [SVProgressHUD showWithStatus:@"Signing in"];

             [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {




                 [QBRequest logInWithUserLogin:user.login password:password successBlock:^(QBResponse *response, QBUUser *user) {
                     [self registerForRemoteNotifications];




                     [SVProgressHUD showSuccessWithStatus:@"You've successfully signed up"];


                     [self performSegueWithIdentifier:@"confirmedSeg" sender:nil];

                 } errorBlock:^(QBResponse *response) {
                     [SVProgressHUD dismiss];


                     NSLog(@"Errors=%@", [response.error description]);
//                     [SVProgressHUD showErrorWithStatus:[response.error description]];

                 }];

             } errorBlock:^(QBResponse *response) {
                 [SVProgressHUD dismiss];

                 NSLog(@"Errors=%@", [response.error description]);


             }];


         } else {

             // Ask user to re-attempt verification

             [SVProgressHUD showErrorWithStatus:@"Wrong Code Entered! Try again"];
             // Pop animation for button to animate on error
             POPSpringAnimation *shake = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
             shake.springBounciness = 20;
             shake.velocity = @(3000);
             [self.code.layer pop_addAnimation:shake forKey:@"shakePassword"];

             [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:10.0 options:nil animations:^{
                 self.verifyButton.bounds = CGRectMake(self.verifyButton.bounds.origin.x - 20, self.verifyButton.bounds.origin.y, self.verifyButton.bounds.size.width + 20, self.verifyButton.bounds.size.height);
                 self.verifyButton.enabled = true ;
                 [self.verifyButton setTitleColor:[UIColor colorWithRed:255.0 green:0.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];

             } completion:nil];
         }
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"confirmedSeg"]){
        IntroToProfileViewController* vc = [segue destinationViewController];
        vc.phoneDigits = self.phoneDigits;
    }
}
- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)signup:(id)sender {

    [self.view endEditing:YES];

    QBUUser *user = [QBUUser new];
    user.login = self.phoneDigits;
    user.password = @"samplePassword";
    NSString *password = @"samplePassword";
    NSString *login = self.phoneDigits;
    
    
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        
        [SVProgressHUD showSuccessWithStatus:@"You've successfully signed up"];
        [self performSegueWithIdentifier:@"MainScreenSeg" sender:self];
        
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];
        
        NSLog(@"Errors=%@", [response.error description]);
        
        
    }];
}


@end
