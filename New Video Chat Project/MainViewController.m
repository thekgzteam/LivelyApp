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

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NMPaginatorDelegate, QBChatDelegate, QBRTCClientDelegate,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UsersPaginator *paginator;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDialogs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *EditDialogsBarButton;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *currentSession;
@property (weak, nonatomic) QBRTCSession *sessionToAccept;
@property (strong, nonatomic) IBOutlet UISearchController *searchControllers;
@property NSArray *filteredResults;
@property (weak, nonatomic) IBOutlet UILabel *allTextsButtonAndNumberOfDialogs;
@property (weak, nonatomic) IBOutlet UIButton *createGroupChatButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView.hidden = YES;

//    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 88)];
//    self.createGroupChatButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 88)];
//
//    [buttonView addSubview:self.createGroupChatButton];
//    self.tableView.tableHeaderView = buttonView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);

    self.createGroupChatButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.createGroupChatButton.layer.borderWidth = 1.5f;

    self.searchControllers = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchControllers.searchResultsUpdater = self;
    self.searchControllers.delegate = self;
    self.searchControllers.dimsBackgroundDuringPresentation = false;
    [self.searchControllers.searchBar  sizeToFit];

    self.liveIndexPaths = [NSMutableArray new];


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

    // FETCHING CURRENT USER IMAGE FOR DIALOG CHATHEAD
    QBUUser *currentuser = [QBSession currentSession].currentUser;
    NSUInteger userProfilePictureID = currentuser.blobID; // user - an instance of QBUUser class

    [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse *  response, NSData *fileData) {

        self.currentUserImageToBePassed = [UIImage imageWithData:fileData];

    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
        nil;
    } errorBlock:^(QBResponse * _Nonnull response) {
    }];


    // REQUEST FOR COUNT OF DIALOGS
    [QBRequest countOfDialogsWithExtendedRequest:nil successBlock:^(QBResponse *response, NSUInteger count) {
        NSString *integerAsString = [@(count) stringValue];
        NSString *numberOfDialogs = [NSString stringWithFormat:@"Messages (%@)", integerAsString];
        self.allTextsButtonAndNumberOfDialogs.text = numberOfDialogs;
            } errorBlock:^(QBResponse *response) {
    }];
        [self loadDialogs];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.tableView.tableHeaderView.hidden = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];

    NSLog(@"----------%ld------", [QBSession currentSession].currentUser.ID);


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
//        [SVProgressHUD showWithStatus:@"Loading history"];
        [weakSelf.paginator fetchFirstPage];
    });
}

- (void)receiveReloadTableViewNotification:(NSNotification *) notification {
    [self loadDialogs];
}

#pragma mark - QBCHAT DIALOG METHODS -

// FETCHING DIALOGS LAST MESSAGES
- (void)loadDialogs {
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];

    __weak MainViewController *wSelf = self;
    [QBRequest dialogsForPage:page extendedRequest:nil successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        wSelf.textMessages = dialogObjects;
        wSelf.userPhotos = [NSMutableArray arrayWithCapacity:dialogObjects.count];

        for (id o in dialogObjects) {
            [wSelf.userPhotos addObject:[NSNull null]];
        }
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
//    [SVProgressHUD showSuccessWithStatus:@"Successfully connected to chat"];
    [QBSettings setKeepAliveInterval:30];
    [QBSettings setAutoReconnectEnabled:YES];
}

- (void)chatDidNotConnectWithError:(NSError *)error {
//    [SVProgressHUD showErrorWithStatus:@"Error connecting to chat"];
}

#pragma mark - TABLE VIEW METHODS -

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchControllers.active) {
        return self.filteredResults.count;
    }
    else
    {
        return self.textMessages.count;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}

- (MainTableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincellid"];

    CGFloat r = (float)rand()/RAND_MAX;
    CGFloat g = (float)rand()/RAND_MAX;
    CGFloat b = (float)rand()/RAND_MAX;
    UIColor *newColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    cell.colorLabel.backgroundColor = newColor;

    if(cell == nil)
    {
        cell = [[MainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"maincellid"];

    }

    QBChatDialog *allDialogs = [self.textMessages objectAtIndex:indexPath.row];
    UIImage *photo = [self.userPhotos objectAtIndex:indexPath.row];


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

//            if (![photo isEqual:[NSNull null]]) {
//                cell.profileImage.image = photo;
//            } else {
                NSUInteger indexID = [allDialogs.photo integerValue];
                __weak MainViewController *wSelf = self;
                [QBRequest downloadFileWithID:indexID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {

                    if (fileData == nil) {
                        cell.profileImage.image = [UIImage imageNamed:@"group icon-1"];
                    } else {
                        cell.profileImage.image = [UIImage imageWithData:fileData];
                    }
//                    UIImage *userImage = [UIImage imageWithData:fileData];
//
//                    if (userImage == nil) {
//                         [wSelf.userPhotos insertObject:[UIImage imageNamed:@"group icon-1"] atIndex:indexPath.row];
//    
//                    } else {
//
//                        [wSelf.userPhotos insertObject:userImage atIndex:indexPath.row];
//                    }
//
//                    cell.profileImage.image = [wSelf.userPhotos objectAtIndex:indexPath.row];

                } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                    nil;
                } errorBlock:nil];
//            }
        };
//               cell.profileImage.image = [UIImage imageNamed:@"group icon-1"];



               if (self.searchControllers.active) {
                   QBChatDialog *allDialogs = [self.filteredResults objectAtIndex:indexPath.row];
                   cell.profileName.text = allDialogs.name;
                   return cell;
               }
               else
               {
            cell.profileName.text = allDialogs.name;
            cell.textMessage.text = allDialogs.lastMessageText;
               }
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

            if (![photo isEqual:[NSNull null]]) {
                cell.profileImage.image = photo;
            } else {

            NSArray *userids = [[NSArray alloc]initWithObjects:@(allDialogs.recipientID), nil];
            [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                for (QBUUser *user in users) {
                    NSUInteger userProfilePictureID = user.blobID;

                    __weak MainViewController *wSelf = self;
                    [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
                        UIImage *userImage = [UIImage imageWithData:fileData];

                        if (userImage == nil) {
                            [wSelf.userPhotos insertObject:[UIImage imageNamed:@"Profile Picture"] atIndex:indexPath.row];

                        } else {

                            [wSelf.userPhotos insertObject:userImage atIndex:indexPath.row];
                        }
                        
                        cell.profileImage.image = [wSelf.userPhotos objectAtIndex:indexPath.row];

//                        cell.profileImage.image = [UIImage imageWithData:fileData];



                    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                        nil;
                    } errorBlock:^(QBResponse * _Nonnull response) {
                    }];
                }

            } errorBlock:^(QBResponse *response) {
                // Handle error here
            }];
        }  break;
    }
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

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSLog(@"%@", searchController.searchBar.text);
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF.text contains[c] %@",searchController.searchBar.text];

    NSArray *array = [self.textMessages filteredArrayUsingPredicate:predicate];
    self.filteredResults = (NSArray *)array;
    NSLog(@"%li", array.count);
    [self.tableView reloadData];

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


    if ([self.liveIndexPaths containsObject:indexPath]) {
        NSDictionary *userInfo = @{ @"key" : @"value" };
        [self.sessionToAccept acceptCall:userInfo];
        [self.liveIndexPaths removeObject:indexPath];
        [self performSegueWithIdentifier:@"openDialogSeg" sender:self];

    } else
    {


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
    NSDictionary *userInfo = @{ @"DialogID" : self.userDialogToBePassed.ID };
    [session startCall:userInfo];
    if (session) {
        
        self.currentSession = session;
        self.sessionToAccept = session;
        
        [self performSegueWithIdentifier:@"openDialogSeg" sender:self];
    }
    else {
//        [SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
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
        dvc.currentUserImage = self.currentUserImageToBePassed;
        [segue.destinationViewController hidesBottomBarWhenPushed];
        dvc.navigationController.navigationBarHidden = YES;
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


    NSString *dialogID = userInfo[@"DialogID"];
    MainTableViewCell *cell;
    for (QBChatDialog *dialog in self.textMessages) {
        if ([dialog.ID isEqualToString:dialogID]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.textMessages indexOfObject:dialog] inSection:0];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self.liveIndexPaths addObject:indexPath];
            break;
        }
    }

    if (self.currentSession) {

            [session rejectCall:@{@"reject" : @"busy"}];
        [SVProgressHUD showSuccessWithStatus:@"On Another Call"];
        return;

    } else {

        self.currentSession = session;
        self.sessionToAccept = session;
    cell.isLiveIndicator.hidden = false;
        [SVProgressHUD showSuccessWithStatus:@"🎥"];

    }
}

-(void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    NSLog(@"---%@---",userInfo);

     NSString *dialogID = userInfo[@"DialogID"];
    MainTableViewCell *cell;
    for (QBChatDialog *dialog in self.textMessages) {
        if ([dialog.ID isEqualToString:dialogID]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.textMessages indexOfObject:dialog] inSection:0];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self.liveIndexPaths addObject:indexPath];
            break;
        }
    }

    cell.isLiveIndicator.hidden = true;
    [self.tableView reloadData];

}
-(void)sessionDidClose:(QBRTCSession *)session {
    self.currentSession = nil;
    self.sessionToAccept = nil;

}



-(void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID {




}





- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message{

    [self.tableView reloadData];//    [self.messageArray addObject:message];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];
    
}

@end
