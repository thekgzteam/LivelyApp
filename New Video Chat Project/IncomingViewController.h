//
//  IncomingViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/20/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@protocol IncomingCallViewControllerDelegate;


@interface IncomingViewController : UIViewController <QBChatDelegate,QBRTCClientDelegate>

@property (weak, nonatomic) id <IncomingCallViewControllerDelegate> delegate;
@property (strong, nonatomic) QBRTCSession *session;


@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userProfileName;
@property (weak, nonatomic) IBOutlet UILabel *userProfileStatus;
@property (weak, nonatomic) IBOutlet UIButton *startChatButton;
@property (weak, nonatomic) IBOutlet UIButton *dimissButton;
@property QBChatDialog *privateChat;




@end

@protocol IncomingCallViewControllerDelegate <NSObject>

- (void)incomingCallViewController:(IncomingViewController *)vc didAcceptSession:(QBRTCSession *)session;
- (void)incomingCallViewController:(IncomingViewController *)vc didRejectSession:(QBRTCSession *)session;

@end
