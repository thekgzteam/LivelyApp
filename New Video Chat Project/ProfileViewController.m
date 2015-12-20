//
//  ProfileViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/27/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#import "ProfileViewController.h"

#import "POP.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"

#import "ProfileSettingsViewController.h"
#import "RegistrationViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>



@interface ProfileViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileDescription;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *sendFeedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *legalButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    NSUInteger userProfilePictureID = [QBSession currentSession].currentUser.blobID;
    [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse *  response, NSData *fileData) {
        NSLog(@"--------%@------",fileData);

        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
        self.profilePic.image = [UIImage imageWithData:fileData];
    } statusBlock:^(QBRequest *  request, QBRequestStatus *  status) {
        NSLog(@"--------%@------",status.description);


    } errorBlock:^(QBResponse *  response) {
        NSLog(@"--------%@------",response.error);
    }];


    [QBRequest userWithID:[QBSession currentSession].currentUser.ID successBlock:^(QBResponse *response, QBUUser *user) {

        if (user.website == nil) {
            self.profileDescription.text = @"I Love Lively";
        } else {
            NSString *str = user.website;
            NSString *newStr = [str substringFromIndex:7];
            self.profileDescription.text = newStr;
        }
        self.profileName.text = user.fullName;

    } errorBlock:^(QBResponse *response) {
    }];


    self.profilePic.layer.cornerRadius = 60;
    self.profilePic.layer.masksToBounds = YES;
    self.profilePic.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.profilePic.layer.borderWidth = 4.0f;

    self.profileDescription.layer.cornerRadius = 18;
    self.profileDescription.layer.masksToBounds = YES;

    self.logOutButton.layer.cornerRadius = 70;
    self.logOutButton.layer.masksToBounds = YES;



}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [self.profilePic.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileName.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileDescription.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.shareButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.sendFeedbackButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.helpButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.legalButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.logOutButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.settingsButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];

    [self.profileDescription.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.shareButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.sendFeedbackButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.helpButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.legalButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.logOutButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.settingsButton.layer addAnimation:[self rotationAnimation] forKey:@"rotationAnimation"];

}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];


   }


- (IBAction)didClickOnPresent:(id)sender {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSecondViewController)
                                                 name:@"SecondViewControllerDismissed"
                                               object:nil];

    ProfileSettingsViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profileSettings"];
    modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:modalVC animated:NO completion:nil];

}

-(void)didDismissSecondViewController {
    [self viewDidLoad];

}
- (IBAction)sendFeedbackButton:(id)sender {

    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;

        [mailCont setSubject:@"Please Specify App Bug Subject"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"thekgzteam@gmail.com"]];
        [mailCont setMessageBody:@"PLease Specify a Bug, Thank You, Lively Administration" isHTML:NO];

        [self presentModalViewController:mailCont animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionButtonPressed:(id)sender {

    NSString *string = @"Hey Check out This New app Lively, Here the Link To Download it";
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[string]
                                                                             applicationActivities:nil];
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    [self presentViewController:activityVC animated:YES completion:nil];
}

//if iPad
else {
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
#pragma mark - UIViewControllerTransitionDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

- (IBAction)logoutButtonClicked:(id)sender {

    [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        // Successful logout
        [SVProgressHUD showSuccessWithStatus:@"Signed Out"];

        [self performSegueWithIdentifier:@"logoutSeg" sender:nil];

    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:@"Error Signing Out"];
    }];
}

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.fromValue          = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];;
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    transformAnim.duration           = 0.398;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}

- (CABasicAnimation*)ovalAnimationOpacity{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.652;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    return opacityAnim;
}

- (CABasicAnimation*)rotationAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    transformAnim.toValue            = @(-360 * M_PI/180);
    transformAnim.duration           = 0.435;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}

@end
