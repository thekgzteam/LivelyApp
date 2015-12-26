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
#import <UIImageView+WebCache.h>


@interface ProfileSettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileStatus;
@property (weak, nonatomic) IBOutlet UIButton *dismissPSetVC;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property NSString *fullNameHolder;
@property NSString *statusHolder;

@property UIImage *image;
@property UIImagePickerController *pickerController;
@property UIActionSheet *actionSheet;
@property UIActionSheet *actionSheet2;



@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.profileImage setUserInteractionEnabled:YES];
    [self.profileNameLabel setUserInteractionEnabled:YES];
    [self.profileStatus setUserInteractionEnabled:YES];

    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    UITapGestureRecognizer *singleTapGestureRecognizerName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureName:)];
    UITapGestureRecognizer *singleTapGestureRecognizerStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureStatus:)];


    [self.profileImage addGestureRecognizer:singleTapGestureRecognizer];
    [self.profileNameLabel addGestureRecognizer:singleTapGestureRecognizerName];
    [self.profileStatus addGestureRecognizer:singleTapGestureRecognizerStatus];

    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizerName.numberOfTapsRequired = 1;
    singleTapGestureRecognizerStatus.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.delegate = self;
    singleTapGestureRecognizerStatus.delegate = self;
    singleTapGestureRecognizerName.delegate = self;

    // UI DESIGN
    self.saveChangesButton.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.view.layer.cornerRadius = 8.f;
    self.dismissPSetVC.layer.cornerRadius = 23.0f;
    self.saveChangesButton.layer.cornerRadius = 30.f;
    self.saveChangesButton.layer.masksToBounds = YES;
    self.saveChangesButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.saveChangesButton.layer.borderWidth = 2.0f;

    self.editProfileButton.layer.cornerRadius = 30.f;
    self.editProfileButton.layer.masksToBounds = YES;
    self.editProfileButton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.editProfileButton.layer.borderWidth = 2.0f;


    self.profileImage.layer.cornerRadius = 63.f;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor colorWithRed:22.0 green:160.0 blue:133.0 alpha:1.0f].CGColor;
    self.profileImage.layer.borderWidth = 4.0f;

//  FETCHING CURRENT USER AVATAR
    NSUInteger userProfilePictureID = [QBSession currentSession].currentUser.blobID;

    NSString *privateUrl = [QBCBlob privateUrlForID:userProfilePictureID];

    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                       placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              }];

//  FETCHING CURRENT USER NAME AND STATUS
    [QBRequest userWithID:[QBSession currentSession].currentUser.ID successBlock:^(QBResponse *response, QBUUser *user) {
        self.profileNameLabel.text = user.fullName;
        NSString *str = user.website;
        NSString *newStr = [str substringFromIndex:7];
        self.profileStatus.text = newStr;
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];

// UI ANIMATION
    [self.profileImage.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileImage.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.profileImage.layer addAnimation:[self rotationAnimation] forKey:@"rotationAnimation"];
    [self.profileNameLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileNameLabel.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.profileStatus.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.profileStatus.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.saveChangesButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.saveChangesButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];

    [self.editProfileButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.editProfileButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];

    [self.dismissPSetVC.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.dismissPSetVC.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.view.frame = CGRectMake(30,100, 330.f, 420.f);
}

-(void)saveButtonEnabled {
    self.saveChangesButton.hidden = NO;
}


-(void)tapGestureName:(UITapGestureRecognizer *)tapGestureRecognizerForName {
    [self showAlertController];
}

-(void)tapGestureStatus:(UITapGestureRecognizer *)tapGestureRecognizerForStatus {
    [self showAlertControllerForStatus];
}

- (IBAction)editProfileButtonPressed:(id)sender {

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        self.actionSheet2 = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Photo", @"Choose From Library", @"Change Name", @"Change Status", nil];
        [self.actionSheet2 showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }



}

-(void)tapGesture:(UITapGestureRecognizer *)tapGestureRecognizer2 {

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
    self.actionSheet.tag = 1;

}


#pragma mark - USER INTERACTION
- (IBAction)onDismissButtonPressed:(id)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

- (IBAction)onSaveChangesButtonPressed:(id)sender {

    [self saveImage];
    [self updateFullName];
    [self updateStatus];
    self.saveChangesButton.hidden = YES;
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

-(void)saveImage {
//    [SVProgressHUD showWithStatus:@"Saving"];
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
//                          NSLog(@"Failed to update user: %@", [response.error reasons]);
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

#pragma mark - ALERTCONTROLLERS

-(void)showAlertController {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Full Name" message:@"Please Type In To Update Your Name" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];

    __weak ProfileSettingsViewController *wSelf = self;
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UITextField *nameTextField = [[alert textFields]firstObject];
        wSelf.fullNameHolder = nameTextField.text;
        wSelf.profileNameLabel.text = nameTextField.text;
        [self saveButtonEnabled];
        self.editProfileButton.hidden = YES;

            }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:createAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showAlertControllerForStatus {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Status" message:@"Please Type In To Update Your Status" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];

    __weak ProfileSettingsViewController *wSelf = self;
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *status = [[alert textFields]firstObject];
        wSelf.statusHolder = status.text;
        wSelf.profileStatus.text = status.text;
        self.editProfileButton.hidden = YES;

        [self saveButtonEnabled];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:createAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateStatus {

    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.website = self.profileStatus.text;

    [QBRequest updateCurrentUser:params successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
    } errorBlock:^(QBResponse * _Nonnull response) {
    }];
}

- (void)updateFullName {

    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.fullName = self.fullNameHolder;

    [QBRequest updateCurrentUser:params successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {

    } errorBlock:^(QBResponse * _Nonnull response) {
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
    self.actionSheet2.tag = 2;
}

#pragma mark - Image

- (void)showImage:(UIImage *)image {

    self.profileImage.image = image;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [self saveButtonEnabled];
    self.editProfileButton.hidden = YES;
    self.image = info[UIImagePickerControllerEditedImage];
    [self showImage:self.image];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            [self takePhoto];

        } else if (buttonIndex == 1) {
            [self choosePhotoFromLibrary];
        }else
            self.actionSheet = nil;
    } else {
        if (buttonIndex == 0) {
            [self takePhoto];

        } else if (buttonIndex == 1) {
            [self choosePhotoFromLibrary];

        }else if (buttonIndex == 2) {
            [self showAlertController];

        }else if (buttonIndex == 3) {
            [self showAlertControllerForStatus];
        }
        self.actionSheet2 = nil;
    }


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
