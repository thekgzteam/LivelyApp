//
//  IntroToProfileViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#import "IntroToProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"

@interface IntroToProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *ProfileDoneButton;
@property (weak, nonatomic) IBOutlet UITextField *EnterNameTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *image;
@property UIImagePickerController *picker2;
@property UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property NSArray *objects;
@property UIActionSheet *actionSheet;


@end

@implementation IntroToProfileViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.actionSheet.delegate self];

    self.imageView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    self.imageView.layer.cornerRadius= 50;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor=[[UIColor redColor] CGColor];
    NSLog(@"%@", self.phoneDigits);



}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.2;
    border.borderColor = [UIColor grayColor].CGColor;
    border.frame = CGRectMake(0, self.EnterNameTextfield.frame.size.height - borderWidth, self.EnterNameTextfield.frame.size.width, self.EnterNameTextfield.frame.size.height);
    border.borderWidth = borderWidth;
    [self.EnterNameTextfield.layer addSublayer:border];
    self.EnterNameTextfield.layer.masksToBounds = YES;

    self.ProfileDoneButton.layer.cornerRadius = 15;
    self.ProfileDoneButton.layer.masksToBounds = YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.EnterNameTextfield isFirstResponder] && [touch view] != self.EnterNameTextfield)
        [self.EnterNameTextfield resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)isLoginEmpty
{
    BOOL emptyLogin = self.EnterNameTextfield.text.length == 0;
    self.EnterNameTextfield.backgroundColor = emptyLogin ? [UIColor redColor] : [UIColor whiteColor];
    return emptyLogin;
}


#pragma - user interaction -
- (IBAction)ChooseExisting {
    self.picker2 =[[UIImagePickerController alloc] init];
    self.picker2.delegate = self;
    [self.picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.picker2 animated:YES completion:NULL];
}

- (IBAction)Camera {
    self.picker =[[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    [self.picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:self.
     picker animated:YES completion:NULL];

}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageView setImage:self.image];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)updateUserInfo:(id)sender {

    [SVProgressHUD showWithStatus:@"Updating profile"];

    QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
    if (self.EnterNameTextfield.text.length > 0)
        updateParameters.fullName = self.EnterNameTextfield.text;

    // your file - this is an image in our case
    NSData * imageData = UIImageJPEGRepresentation (self.imageView.image, 0.7);

     [QBRequest TUploadFile:imageData fileName:@"Profile Picture"  contentType:@"image/jpeg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {


         NSLog(@"-----------------Image is Uploaded---------------");
        // File uploaded, do something
        // if blob.isPublic == YES
        QBUpdateUserParameters *params = [QBUpdateUserParameters new];
        params.blobID = [QBSession currentSession].currentUser.blobID;


        [QBRequest updateCurrentUser:params successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
            NSLog(@"------>>>>>>>>>>>>>>successfully updated image<<<<<<");
            // success block
        } errorBlock:^(QBResponse * _Nonnull response) {
            // error block
            NSLog(@"------>>>Failed to update user: %@<<<", [response.error reasons]);
        }];

    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        // handle progress
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
    }];

    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
        [SVProgressHUD showSuccessWithStatus:@"Saved"];
        [self performSegueWithIdentifier:@"MainScreenSeg" sender:self];

    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD dismiss];

        NSLog(@"Errors=%@", [response.error description]);
        [SVProgressHUD showSuccessWithStatus:[response.error description]];
    }];
}

- (IBAction)showNormalActionSheet:(id)sender {


    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Actions?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Take a Picture"
                                                    otherButtonTitles:@"Photo Library", nil];
    [actionSheet showInView:self.view];



}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        [self Camera];
    }
    else if (actionSheet.tag == 2){
        [self ChooseExisting];
    }

    [self Camera], [self ChooseExisting] , buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex];
}


- (IBAction)onSkipButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"MainScreenSeg" sender:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainScreenSeg"]) {
        SWRevealViewController *mainVC = segue.destinationViewController;
        mainVC.myUserId = self.EnterNameTextfield.text;
    }
}

@end
