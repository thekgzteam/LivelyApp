//
//  MainViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#pragma mark - MAIN VIEW CONTROLLER AND CELL
#import "MainViewController.h"
#import "MainTableViewCell.h"

#pragma mark - FRAMEWORKS
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import "SWRevealViewController.h"
#import "SVProgressHUD.h"
#import <UIImageView+WebCache.h>


#pragma mark - ALL OTHER IMPORTED VIEWS
#import "Storage.h"
#import "UsersPaginator.h"
#import "NMPaginator.h"
#import "ProfileViewController.h"
#import "DialogViewController.h"
#import "CreatGroupVC.h"
#import "ContactsAndGroups.h"
#import "IncomingViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NMPaginatorDelegate, QBChatDelegate, QBRTCClientDelegate>

@property (nonatomic, strong) UsersPaginator *paginator;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDialogs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *EditDialogsBarButton;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *currentSession;
@property (weak, nonatomic) QBRTCSession *sessionToAccept;
@property MainTableViewCell *mainVcCell;

@property (weak, nonatomic) IBOutlet UILabel *allTextsButtonAndNumberOfDialogs;
@property BOOL isOnline;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isOnline = false;

#pragma mark -  NSNOTIFICATIONS

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadTableViewNotification:)
                                                 name:@"reloadTableViewNotification"
                                               object:nil];

    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];


#pragma mark - UI DESIGN -

    // WRITE NEW MESSAGE CUSTOM BUTTON

  CGRect frame = CGRectMake(0,0, 200, 50);
    UIView *customView;
    customView.frame = frame;
    self.nav.navigationItem.titleView.frame =frame;
    [self.nav.navigationItem.titleView sizeToFit];
    
    self.navigationItem.titleView.frame = frame;
    self.navigationController.navigationItem.titleView.frame = frame;



    self.writeNewMessage.layer.cornerRadius = 30;
    self.writeNewMessage.layer.masksToBounds = YES;
    self.writeNewMessage.layer.borderColor=[[UIColor redColor] CGColor];
    [self.writeNewMessage.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];

#pragma mark - SIDE BAR CONTACTS AND GROUPS
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ) {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

#pragma mark - QBCHAT DIALOG METHODS -

    // REQUEST FOR COUNT OF DIALOGS
    [QBRequest countOfDialogsWithExtendedRequest:nil successBlock:^(QBResponse *response, NSUInteger count) {
        NSString *integerAsString = [@(count) stringValue];
        NSString *numberOfDialogs = [NSString stringWithFormat:@"All Texts (%@)", integerAsString];
        self.allTextsButtonAndNumberOfDialogs.text = numberOfDialogs;
            } errorBlock:^(QBResponse *response) {
    }];
        [self loadDialogs];
}

- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];

#pragma mark - CONNECTING TO CHAT AND WEBRTCVIDEO

    [QBRTCClient initializeRTC];

    [QBRTCClient.instance addDelegate:self];
    [[QBChat instance] addDelegate:self];


    QBUUser *user = [QBUUser user];
    user.ID = [QBSession currentSession].currentUser.ID;
    user.password = @"samplePassword";

    [[QBChat instance] connectWithUser:user completion:nil];

    __weak typeof(self)weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SVProgressHUD showWithStatus:@"Loading history"];
        [weakSelf.paginator fetchFirstPage];
    });
}

- (void)receiveReloadTableViewNotification:(NSNotification *) notification {
    [self loadDialogs];

    [SVProgressHUD showSuccessWithStatus:@"tableView is reloading"];
}

#pragma mark - QBCHAT DIALOG METHODS -

// FETCHING DIALOGS LAST MESSAGES
- (void)loadDialogs {
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];

    __weak MainViewController *wSelf = self;
    [QBRequest dialogsForPage:page extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        wSelf.textMessages = dialogObjects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf.tableView reloadData];
        });
        [wSelf.tableView reloadData];
    } errorBlock:^(QBResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
}

#pragma mark - USERS PAGINATOR

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results {
    [[Storage instance].users addObjectsFromArray:results];
    [self.tableView reloadData];
}

#pragma mark - CONNECTING TO CHAT
- (void) chatDidConnect{
    [SVProgressHUD showSuccessWithStatus:@"Successfully connected to chat"];
    [QBSettings setKeepAliveInterval:30];
    [QBSettings setAutoReconnectEnabled:YES];
}

- (void)chatDidNotConnectWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"Error connecting to chat"];
}

#pragma mark - TABLE VIEW METHODS -

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textMessages.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (MainTableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincellid"];
    QBChatDialog *allDialogs = [self.textMessages objectAtIndex:indexPath.row];


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.doesRelativeDateFormatting = YES;

    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"HH:mm"];
    NSString *startTimeString = [formatter2 stringFromDate:allDialogs.lastMessageDate];
    NSString *dialogCreatedDate = [formatter2 stringFromDate:allDialogs.createdAt];

    NSString *result = [formatter stringFromDate:allDialogs.lastMessageDate];

       switch (allDialogs.type) {
        case QBChatDialogTypeGroup: {

            [QBRequest downloadFileWithUID:allDialogs.photo successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {

//                cell.profileImage.image = [UIImage imageWithData:fileData];
                   cell.profileImage.image = [UIImage imageNamed:@"group icon-1"];

            } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                nil;
            } errorBlock:nil];
        };
//               cell.profileImage.image = [UIImage imageNamed:@"group icon-1"];

            cell.profileName.text = allDialogs.name;
            cell.textMessage.text = allDialogs.lastMessageText;

            if ([result isEqualToString:@"Today"]) {
                cell.timeOfMessage.text = startTimeString;

            } else if (result == nil) {
                cell.timeOfMessage.text = dialogCreatedDate;

            } else {
                cell.timeOfMessage.text = result;

        break;
        case QBChatDialogTypePrivate: {

            NSMutableArray *occID = [[NSMutableArray alloc]initWithArray:allDialogs.occupantIDs];

            [occID removeObject:@([QBSession currentSession].currentUser.ID)];

            __weak MainViewController *wSelf = self;
            [QBRequest usersWithIDs:occID page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                       successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                           for (QBUUser *user in users) {
                               wSelf.usersRetrievedFullName = user.fullName;
                               cell.profileName.text = self.usersRetrievedFullName;
                           }
                       } errorBlock:^(QBResponse *response) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                           });
                       }];
            cell.textMessage.text = allDialogs.lastMessageText;
            if ([result isEqualToString:@"Today"]) {
                cell.timeOfMessage.text = startTimeString;
            } else if (result == nil) {

                cell.timeOfMessage.text = dialogCreatedDate;

            } else {

                cell.timeOfMessage.text = result;
            }
            cell.profileImage.image = [UIImage imageNamed:@"Profile Picture"];


            NSArray *userids = [[NSArray alloc]initWithObjects:@(allDialogs.recipientID), nil];
            [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                for (QBUUser *user in users) {
                    NSUInteger userProfilePictureID = user.blobID;

                    __weak MainViewController *wSelf = self;
                    [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
                        // Here we use the new provided sd_setImageWithURL: method to load the web image
//                        [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
//                                          placeholderImage:[UIImage imageWithData:fileData]];

                        cell.profileImage.image = [UIImage imageWithData:fileData];



                    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                        nil;
                    } errorBlock:^(QBResponse * _Nonnull response) {
                    }];
                }

            } errorBlock:^(QBResponse *response) {
                // Handle error here
            }];

        }  break;
        case QBChatDialogTypePublicGroup: {
            cell.profileName.text = allDialogs.name;
            cell.textMessage.text = allDialogs.lastMessageText;
            cell.profileImage.image = [UIImage imageNamed:@"Profile Picture"];
            if ([result isEqualToString:@"Today"]) {
                cell.timeOfMessage.text = startTimeString;
            } else if (result == nil) {
                cell.timeOfMessage.text = dialogCreatedDate;
            } else {
                cell.timeOfMessage.text = result;
            }
        }
            break;
        default:
            break;
        }
    }
    
    // UNREAD MESSAGES
    BOOL hasUnreadMessages = allDialogs.unreadMessagesCount > 0;
    cell.unreadMessagesCountLabel.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString* unreadText = nil;
        if (allDialogs.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%lu", (unsigned long)allDialogs.unreadMessagesCount];
        }
        cell.unreadMessagesCountLabel.text = unreadText;
    } else {
        cell.unreadMessagesCountLabel.text = nil;
    }
    return cell;
}

#pragma mark - USER INTERACTION -

- (IBAction)createGroupChat:(id)sender {
    CreatGroupVC *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"createGroupVC"];
    modalVC.transitioningDelegate = self;
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (IBAction)startNewChatButton:(id)sender {
    ContactsAndGroups *contactsVC =
    [self.storyboard instantiateViewControllerWithIdentifier:@"ContactListVC"];
    contactsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:contactsVC animated:YES completion:nil];
}

#pragma mark - EDIT AND DELETE DIALOGS
- (IBAction)onEditDialogButtonPressed:(id)sender {

    if(self.editing) {
        [super setEditing:NO animated:NO];
        [self.tableView setEditing:NO animated:NO];
        [self.tableView reloadData];
        [self.EditDialogsBarButton setTitle:@"Edit"];
    }
    else {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];
        [self.EditDialogsBarButton setTitle:@"Done"];
    }
}

- (NSString *)senderDisplayName {
    return [QBSession currentSession].currentUser.fullName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    MainTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    self.navBarTitle = cell.profileName.text;
    self.imageToDialogVC = cell.profileImage.image;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.userDialogToBePassed = self.textMessages[indexPath.row];



    if (self.isOnline == true) {
        NSDictionary *userInfo = @{ @"key" : @"value" };

        [self.sessionToAccept acceptCall:userInfo];
        [self performSegueWithIdentifier:@"openDialogSeg" sender:self];

    } else if (self.isOnline == false) {


#pragma mark - MAKING A VIDEO CALL
    NSMutableArray *opponentsIDs = [self.userDialogToBePassed.occupantIDs mutableCopy];
    NSInteger currentUserID = [QBSession currentSession].currentUser.ID;
    int count = 0;
    NSNumber *currentUserIndex = nil;
    for (NSNumber *opponentID in opponentsIDs) {
        if ([opponentID integerValue] == currentUserID) {
            currentUserIndex = @(count);
            break;
        }
        count++;
    }
    if (currentUserIndex) [opponentsIDs removeObjectAtIndex:[currentUserIndex intValue]];
    QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                                             withConferenceType:QBRTCConferenceTypeVideo];
    NSDictionary *userInfo = @{ @"key" : @"value" };
    [session startCall:userInfo];
    if (session) {
        
        self.currentSession = session;
        self.sessionToAccept = session;
        [QBRequest sendPushWithText:[[self senderDisplayName] stringByAppendingString:@" is Live 🎥 "] toUsers:[opponentsIDs mutableCopy] successBlock:nil errorBlock:^(QBError *error) {
        }];

        [self performSegueWithIdentifier:@"openDialogSeg" sender:self];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
    }
    }
}
#pragma mark - SEGUES -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"openDialogSeg"]) {
        DialogViewController *dvc = segue.destinationViewController;
        dvc.userFullName = self.navBarTitle;
        dvc.userDialogs = self.userDialogToBePassed;
        dvc.session = self.currentSession;
        dvc.imageForRightBar = self.imageToDialogVC;
        dvc.session = self.sessionToAccept;
    }
}


#pragma mark - UI ANIMATION METHODS

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.fromValue          = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];;
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    transformAnim.duration           = 0.398;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}


- (CABasicAnimation*)isLiveAnimation{
    CABasicAnimation * fillColorAnim = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillColorAnim.toValue            = (id)[UIColor colorWithRed:0.0755 green: 0.922 blue:0 alpha:1].CGColor;
    fillColorAnim.duration           = 0.733;
    fillColorAnim.autoreverses       = YES;
    fillColorAnim.fillMode = kCAFillModeForwards;
    fillColorAnim.removedOnCompletion = NO;
    fillColorAnim.repeatCount = 200;

    return fillColorAnim;
}

#pragma mark - UIVIEWCONTROLLER TRANSITION DELEGATE METHODS

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

#pragma mark -
#pragma mark QBRTCClientDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {


    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    MainTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];

//    if (self.currentSession) {
//        [SVProgressHUD showSuccessWithStatus:@"call is rejected"];
//        [session rejectCall:@{@"reject" : @"busy"}];
//        return;
//    } else {
        self.isOnline = true;
        self.currentSession = session;
        self.sessionToAccept = session;
        [cell.layer addAnimation:[self isLiveAnimation] forKey:@"isLiveAnimation"];
        cell.isLiveIndicator.hidden = false;
    self.mainVcCell.isLiveIndicator.hidden = false;
        [SVProgressHUD showSuccessWithStatus:@"call is coming"];
        [self.tableView reloadData];
//    }
//                [cell.layer removeAllAnimations];
//                    self.isOnline = false;


//    //    NSParameterAssert(!self.nav);
//    IncomingViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
//    dvc.session = self.currentSession;
//    dvc.transitioningDelegate = self;
//    dvc.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:dvc animated:YES completion:nil];
}

-(void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {


}
-(void)sessionDidClose:(QBRTCSession *)session {
}

@end