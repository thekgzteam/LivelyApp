//
//  CreatGroupVC.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/12/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "POP.h"
#import "SVProgressHUD.h"

#import "CreatGroupVC.h"
#import "ContactListViewController.h"

@interface CreatGroupVC () 

@property (weak, nonatomic) IBOutlet UIButton *dismissVC;
@property (weak, nonatomic) IBOutlet UIImageView *uploadGroupImage;
@property (weak, nonatomic) IBOutlet UITextField *GroupName;
@property (weak, nonatomic) IBOutlet UIButton *nextbutton;
@property UIImage *image;
@property UIImagePickerController *picker2;
@property UIImagePickerController *pickerController;
@property UIActionSheet *actionSheet;

@end

@implementation CreatGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];

#pragma mark - UI DESIGN -

    self.view.layer.cornerRadius = 8.f;

    self.dismissVC.layer.cornerRadius = 17.0f;
    self.nextbutton.layer.cornerRadius = 25.f;

    self.nextbutton.layer.cornerRadius = 23.f;
    self.nextbutton.layer.masksToBounds = YES;
    self.nextbutton.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.nextbutton.layer.borderWidth = 1.0f;

    self.uploadGroupImage.layer.cornerRadius = 66.f;
    self.uploadGroupImage.layer.masksToBounds = YES;
    self.uploadGroupImage.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.uploadGroupImage.layer.borderWidth = 2.0f;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

        self.view.frame = CGRectMake(55,170, 270.f, 340.f);

    // CUSTOM TEXTFIELD FOR ENTERING RECEIVED CODE
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1.5;
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, self.GroupName.frame.size.height - borderWidth, self.GroupName.frame.size.width, self.GroupName.frame.size.height);
    border.borderWidth = borderWidth;
    [self.GroupName.layer addSublayer:border];
    self.GroupName.layer.masksToBounds = YES;
}

#pragma mark - USER INTERACTION -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.GroupName isFirstResponder] && [touch view] != self.GroupName)
        [self.GroupName resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}


- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}



- (IBAction)onClickNextButtonPressed:(id)sender {
    
    if ([self.GroupName.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"Please Enter Group Name"];
        // ANIMATE REQUEST CODE IF TEXTFIELD IS EMPTY
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:10.0 options:nil animations:^{
            self.nextbutton.bounds = CGRectMake(self.nextbutton.bounds.origin.x - 40, self.nextbutton.bounds.origin.y, self.nextbutton.bounds.size.width + 60, self.nextbutton.bounds.size.height);
            self.nextbutton.enabled = true ;
        } completion:nil];
        return;
    } else {
        [self performSegueWithIdentifier:@"createGroupSeg" sender:self];
    }
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

    self.uploadGroupImage.image = image;
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

#pragma mark - SEGUES -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createGroupSeg"]){
    ContactListViewController *dvc = segue.destinationViewController;
    dvc.groupName = self.GroupName.text;
    dvc.uploadImage.image = self.uploadGroupImage.image;
    }
}

@end
