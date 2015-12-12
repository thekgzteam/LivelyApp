//
//  ContactListViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/12/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactListTableViewCell.h"


#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"

#import "Storage.h"
#import "UsersPaginator.h"
#import "NMPaginator.h"


@interface ContactListViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NMPaginatorDelegate>


@property (nonatomic, strong) UsersPaginator *paginator;
@property (nonatomic, weak) UILabel *footerLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createButton;



@end
@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"----------%@-----", self.uploadImage.image);
    [[Storage instance].users removeObject:[QBSession currentSession].currentUser];
    self.createButton.enabled = NO;
    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
}

#pragma mark - TABLE VIEW METHODS -

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[Storage instance].users count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (ContactListTableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactListTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cellid"];

    if (indexPath.section == 0) {

        ContactListTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"cellid"];
        userCell.tag = indexPath.row;

        QBUUser *user = [Storage instance].users[indexPath.row];
        userCell.chooseContactButton.imageView.image = [UIImage imageNamed:@"unchecked"];
        userCell.contactNameLabel.text = user.fullName;

        UIView *bgColorView = [[UIView alloc] init];
        [userCell setBackgroundColor:[UIColor clearColor]];
        [userCell setSelectedBackgroundView:bgColorView];

        cell = userCell;
    }
    return cell;
}

#pragma mark - USER INTERCATION -

- (void)updateSaveButtonState {

    self.createButton.enabled = [[self.tableView indexPathsForSelectedRows] count] != 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self updateSaveButtonState];
    ContactListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.chooseContactButton.imageView.image = [UIImage imageNamed:@"checked"];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self updateSaveButtonState];
    ContactListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.chooseContactButton.imageView.image = [UIImage imageNamed:@"unchecked"];
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results {
    // save files
    [[Storage instance].users addObjectsFromArray:results];
    [self.tableView reloadData];
}

- (IBAction)onCancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

//CREATING GROUP CHAT DIALOG
- (IBAction)onCreateButtonPressed:(id)sender {

    NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
    assert(indexPathArray.count != 0);
    self.userIdInt = [[NSMutableArray alloc]initWithCapacity:indexPathArray.count];

    for (NSIndexPath *indexPath in indexPathArray) {
        QBUUser *user = [Storage instance].users[indexPath.row];

        [self.userIdInt addObject:@(user.ID)];
    }
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypeGroup];
    chatDialog.name = self.groupName;
    chatDialog.occupantIDs = self.userIdInt;

    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {

        [SVProgressHUD showSuccessWithStatus:@"Dialog Created"];
        NSData *avatar = [[NSData alloc] initWithData:UIImagePNGRepresentation(self.uploadImage.image)];
        // Upload a file to the Content module 
//        NSData *imageData = UIImagePNGRepresentation (self.uploadImage.image);

        [QBRequest TUploadFile:avatar fileName:@"Dialod Avatar" contentType:@"image/png" isPublic:NO successBlock:^(QBResponse *response, QBCBlob *uploadedBlob) {
            // set dialog's photo
            NSUInteger uploadedFileID = uploadedBlob.ID;
            createdDialog.photo = [NSString stringWithFormat:@"%d", uploadedFileID];
            
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {

            [QBRequest updateDialog:createdDialog successBlock:^(QBResponse * _Nonnull response, QBChatDialog * _Nullable chatDialog) {
                [SVProgressHUD showSuccessWithStatus:@"Dialog Updated"];
                [self performSegueWithIdentifier:@"groupDialogCreatedSeg" sender:self];

            } errorBlock:^(QBResponse * _Nonnull response) {
                [SVProgressHUD showErrorWithStatus:@"Error Updating the dialog"];
            }];

        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];
 
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:[response.error description]];

    }];
    [SVProgressHUD showWithStatus:@"Creating dialog..." maskType:SVProgressHUDMaskTypeClear];
}

//- (void)howt {
//
////    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:self.chatDialog.ID type:QBChatDialogTypeGroup];
//    chatDialog.name = self.groupName;
//    chatDialog.occupantIDs = @[@([QBSession currentSession].currentUser.ID), @(6742693)];
//
//    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
//
////        // your file - this is an image in our case
////        NSData * imageData = UIImageJPEGRepresentation (self.uploadImage.image, 0.8f);
////
////        [QBRequest TUploadFile:imageData fileName:@"Profile Picture"  contentType:@"image/jpeg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
////
////            // File uploaded, do something
////            // if blob.isPublic == YES
////            QBUpdateUserParameters *params = [QBUpdateUserParameters new];
////            params.blobID = [QBSession currentSession].currentUser.blobID;
////            [QBRequest updateCurrentUser:params successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
////                NSLog(@"------>>>>>>>>successfully updated image");
////                // success block
////            } errorBlock:^(QBResponse * _Nonnull response) {
////                // error block
////                NSLog(@"------>>>Failed to update user: %@<<<", [response.error reasons]);
////            }];
////        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
////            // handle progress
////        } errorBlock:^(QBResponse *response) {
////            NSLog(@"error: %@", response.error);
////        }];
//
//        [SVProgressHUD showSuccessWithStatus:@"Dialog Created"];
//        [self performSegueWithIdentifier:@"groupDialogCreatedSeg" sender:self];
//
//
//    } errorBlock:^(QBResponse *response) {
//        [SVProgressHUD showErrorWithStatus:[response.error description]];
//
//    }];
//}

@end
