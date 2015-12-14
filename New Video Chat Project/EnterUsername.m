//
//  EnterUsername.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/4/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "EnterUsername.h"
#import "MainViewController.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"

@interface EnterUsername ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissViewButton;


@end



@implementation EnterUsername
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.layer.cornerRadius = 8.f;

    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.5;
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, self.usernameTextfield.frame.size.height - borderWidth, self.usernameTextfield.frame.size.width, self.loginButton.frame.size.height);
    border.borderWidth = borderWidth;
    [self.usernameTextfield.layer addSublayer:border];
    self.usernameTextfield.layer.masksToBounds = YES;

    self.usernameTextfield.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 20;
    self.loginButton.layer.masksToBounds = YES;

    self.dismissViewButton.layer.cornerRadius = 15;
    self.dismissViewButton.layer.masksToBounds = YES;


}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.view.frame = CGRectMake (60,157, 280.f, 370.f);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.usernameTextfield isFirstResponder] && [touch view] != self.usernameTextfield)
        [self.usernameTextfield resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}


- (IBAction)login:(id)sender {

    QBUUser *user = [QBUUser user];
    NSString *login = self.usernameTextfield.text;
    user.login = login;
    user.password = @"samplePassword";
    NSString *password = @"samplePassword";


    __weak typeof(self) weakSelf = self;
    [QBRequest logInWithUserLogin:user.login password:password successBlock:^(QBResponse *response, QBUUser *user) {
        [weakSelf registerForRemoteNotifications];

        [SVProgressHUD showSuccessWithStatus:@"You've successfully signed up"];
        [self performSegueWithIdentifier:@"usernameEntered" sender:self];


    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];

        NSLog(@"Errors=%@", [response.error description]);
        [SVProgressHUD showErrorWithStatus:[response.error description]];

    }];

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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"usernameEntered"]){
        MainViewController  *vc = [segue destinationViewController];
        vc.myUserId = self.usernameTextfield.text;
       
    }
}

- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end

