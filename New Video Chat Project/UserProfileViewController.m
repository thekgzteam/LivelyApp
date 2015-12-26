//
//  UserProfileViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/14/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "UserProfileViewController.h"

#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#import "DialogViewController.h"
#import "MainTableViewCell.h"



@interface UserProfileViewController () <QBChatDelegate, DialogViewControllerDelegate,QBRTCClientDelegate>

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

                    for (QBUUser *user  in users) {
                        wSelf.userID = users;
                        wSelf.userIDForChat = user.ID;
                        if (user.website == nil) {
                            wSelf.userProfileStatus.text = @"I Love Lively";
                        } else {
                            NSString *str = user.website;
                            NSString *newStr = [str substringFromIndex:7];
                            wSelf.userProfileStatus.text = newStr;
                        }
                    }
                } errorBlock:^(QBResponse *response) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong UserProfileViewController *sSelf  = wSelf;
                    });
                }];
}

- (void)secondViewScreenControllerDidPressCancelButton:(UIViewController *)viewController sender:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];


}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
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

        NSMutableArray *users = [[NSMutableArray alloc]initWithObjects:@(createdDialog.recipientID), nil];
        QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                                                 withConferenceType:QBRTCConferenceTypeVideo];

        NSDictionary *userInfo = @{ @"DialogID" : createdDialog.ID };

        [session startCall:userInfo];
            [self performSegueWithIdentifier:@"detailChatSeg" sender:self];
        UserProfileViewController *userVC;
        [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
        [userVC dismissViewControllerAnimated:NO completion:nil];
        [self shouldRemovePresentersView];

    } errorBlock:^(QBResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
//        [SVProgressHUD showErrorWithStatus:[response.error description]];

    }];    [[QBChat instance] addDelegate:self];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailChatSeg"]) {
        DialogViewController *dvc = [segue destinationViewController];
        dvc.userFullName = self.userFullName;
        dvc.userDialogs = self.privateChat;
        dvc.passedUserId = self.userIDForChat;
        dvc.imageForRightBar = self.userImage;
        dvc.delegate = self;
        
        // If you don't need any nib don't call the method, use init instead


    }
    }

@end
