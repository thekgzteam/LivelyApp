//
//  UserProfileViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/14/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "UserProfileViewController.h"

#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#import "DialogViewController.h"
#import "MainTableViewCell.h"



@interface UserProfileViewController () <QBChatDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userProfileName;
@property (weak, nonatomic) IBOutlet UILabel *userProfileStatus;
@property (weak, nonatomic) IBOutlet UIButton *startChatButton;
@property (weak, nonatomic) IBOutlet UIButton *dimissButton;
@property QBChatDialog *privateChat;

@end


@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userProfileImage.image = self.userImage;
    self.userIdString = [[NSString alloc]init];
    self.userProfileName.text = self.userFullName;
    self.view.layer.cornerRadius = 8.f;
    self.userProfileImage.layer.cornerRadius = 60;
    self.userProfileImage.layer.masksToBounds = YES;
    self.userProfileImage.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.userProfileImage.layer.borderWidth = 4.0f;
    self.startChatButton.layer.cornerRadius = 20;
    self.startChatButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.startChatButton.layer.borderWidth = 2.0f;
    self.startChatButton.layer.masksToBounds = YES;
    self.dimissButton.layer.cornerRadius = 14;
    self.dimissButton.layer.masksToBounds = YES;


    // Retrieving Selected UserID by passed fullName
    __weak UserProfileViewController *wSelf = self;
    [QBRequest usersWithFullName:self.userFullName page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {

                    wSelf.userIdString = [users valueForKey:@"ID"];
                    for (NSString *userid  in wSelf.userIdString) {
                        wSelf.userIDForChat = [userid integerValue];
                    }
                } errorBlock:^(QBResponse *response) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong UserProfileViewController *sSelf  = wSelf;
                    });
                }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.view.frame = CGRectMake (60,157, 280.f, 370.f);
    
}
- (BOOL) shouldRemovePresentersView {
    return YES;
}

- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)startChat:(id)sender {

    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];

    NSInteger index = self.userIDForChat;
    chatDialog.occupantIDs = @[@(index), @([QBSession currentSession].currentUser.ID)];

    __weak UserProfileViewController *wSelf = self;
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        wSelf.privateChat = createdDialog;

        [self performSegueWithIdentifier:@"detailChatSeg" sender:self];

    } errorBlock:^(QBResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        [SVProgressHUD showErrorWithStatus:[response.error description]];

    }];    [[QBChat instance] addDelegate:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailChatSeg"]) {
        DialogViewController *dvc = [segue destinationViewController];
        dvc.userFullName = self.userFullName;
        dvc.userDialogs = self.privateChat;
        dvc.passedUserId = self.userIDForChat;
        dvc.imageForRightBar = self.userImage;
    }
}

@end
