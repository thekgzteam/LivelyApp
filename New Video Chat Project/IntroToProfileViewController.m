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

@interface IntroToProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *ProfileDoneButton;
@property (weak, nonatomic) IBOutlet UITextField *EnterNameTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property NSArray *objects;
@property UIActionSheet *actionSheet;
@property UIImage *image;
@property UIImagePickerController *pickerController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipButton;

@end

@implementation IntroToProfileViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.EnterNameTextfield.delegate self];

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


#pragma mark - ImagePicker Controller

- (void)takePhoto {
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = YES;
    [self presentViewController:self.pickerController animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary {
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = YES;
    [self presentViewController:self.pickerController animated:YES completion:nil];
}

- (IBAction)updateUserInfo:(id)sender {

    [SVProgressHUD showWithStatus:@"Updating profile"];

    QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
    if (self.EnterNameTextfield.text.length > 0)
        updateParameters.fullName = self.EnterNameTextfield.text;


 NSData * imageData = UIImageJPEGRepresentation (self.imageView.image, 0.15);
 [QBRequest TUploadFile: imageData fileName: @"ProfilePicture"
            contentType: @"image/png"
               isPublic: YES successBlock: ^ (QBResponse * response, QBCBlob * blob) {

             updateParameters.blobID = [blob ID];
        [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                [self performSegueWithIdentifier:@"MainScreenSeg" sender:self];

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

}

- (IBAction)showPhotoMenu:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose From Library", nil];

        [self.actionSheet showInView:self.view];

    } else {

        [self choosePhotoFromLibrary];
    }
}

#pragma mark - Image

- (void)showImage:(UIImage *)image {

    self.imageView.image = image;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {


    self.image = info[UIImagePickerControllerEditedImage];
    [self showImage:self.image];

    [self dismissViewControllerAnimated:YES completion:nil];


}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [self takePhoto];

    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    self.actionSheet = nil;
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {

 }

@end
