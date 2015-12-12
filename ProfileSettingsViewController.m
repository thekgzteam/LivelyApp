//
//  ProfileSettingsViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "ProfileSettingsViewController.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"



@interface ProfileSettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileStatus;
@property (weak, nonatomic) IBOutlet UIButton *dismissPSetVC;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property UIImage *image;
@property UIImagePickerController *pickerController;
@property UIActionSheet *actionSheet;


@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];

    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.profileImage.bounds), CGRectGetMidY(self.profileImage.bounds));



    QBUUser *currentuser = [QBSession currentSession].currentUser;
    NSUInteger userProfilePictureID = currentuser.blobID; // user - an instance of QBUUser class

    [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
        self.profileImage.image = [UIImage imageWithData:fileData];
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];

    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
        nil;
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"-----error gettin pR image----%@---------------", response.error);
    }];


    
    self.view.layer.cornerRadius = 8.f;

    self.dismissPSetVC.layer.cornerRadius = 15.0f;
    self.editProfileButton.layer.cornerRadius = 25.f;
    self.editProfileButton.layer.masksToBounds = YES;
    self.editProfileButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.editProfileButton.layer.borderWidth = 2.0f;

    self.saveChangesButton.layer.cornerRadius = 25.f;
    self.saveChangesButton.layer.masksToBounds = YES;
    self.saveChangesButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.saveChangesButton.layer.borderWidth = 2.0f;

    self.profileImage.layer.cornerRadius = 45.f;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.profileImage.layer.borderWidth = 4.0f;


    [QBRequest userWithID:[QBSession currentSession].currentUser.ID successBlock:^(QBResponse *response, QBUUser *user) {
        self.profileNameLabel.text = user.fullName;
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.view.frame = CGRectMake (60,157, 280.f, 370.f);

}
-(void)viewWillAppear:(BOOL)animated {

    [self.profileImage.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileImage.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.profileImage.layer addAnimation:[self rotationAnimation] forKey:@"rotationAnimation"];
    [self.profileNameLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileNameLabel.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.profileStatus.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileStatus.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.editProfileButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.editProfileButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.saveChangesButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.saveChangesButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.dismissPSetVC.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.dismissPSetVC.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
}


- (IBAction)onDismissButtonPressed:(id)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)onSaveChangesButtonPressed:(id)sender {
    [self saveImage];
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
- (IBAction)saveimagetemp:(id)sender {
}

-(void)saveImage {
    [SVProgressHUD showWithStatus:@"Saving"];
    NSData * imageData = UIImageJPEGRepresentation (self.profileImage.image, 0.15);
    [QBRequest TUploadFile: imageData fileName: @"ProfilePicture"
               contentType: @"image/png"
                  isPublic: YES successBlock: ^ (QBResponse * response, QBCBlob * blob) {

                      QBUpdateUserParameters *params = [QBUpdateUserParameters new];
                      params.blobID = [blob ID];
                      [QBRequest updateCurrentUser:params successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                          [SVProgressHUD showSuccessWithStatus:@"Saved"];
                      } errorBlock:^(QBResponse * _Nonnull response) {
                          // error block
                          NSLog(@"Failed to update user: %@", [response.error reasons]);
                      }];
                  }
               statusBlock: ^ (QBRequest * request, QBRequestStatus * status) {
                   // handle progress
               }
                errorBlock: ^ (QBResponse * response) {
                    NSLog(@"error: %@", response.error);
                }
     ];
}

- (IBAction)showPhotoMenu:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose From Library", @"Edit Name", @"Edit Status", nil];

        [self.actionSheet showInView:self.view];

    } else {

        [self choosePhotoFromLibrary];
    }
}

#pragma mark - Image

- (void)showImage:(UIImage *)image {

    self.profileImage.image = image;
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
