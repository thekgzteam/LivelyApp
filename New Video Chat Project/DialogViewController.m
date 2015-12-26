//
//  DialogViewController.m
//
//
//  Created by Edil Ashimov on 11/3/15.
//
//
#pragma mark - MAIN VIEW CONTROLLER AND CELLS
#import "DialogViewController.h"
#import "IncomingTableViewCell.h"
#import "UserIsTypingCell.h"
#import "OutgointTableViewCell.h"

#pragma mark - FRAMEWORKS
#import "SVProgressHUD.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "POP.h"
#import <UIImageView+WebCache.h>
#import "ContentView.h"
#import "Storage.h"
#import "QCMethod.h"


#pragma mark - ALL OTHER IMPORTED VIEWS
#import "AppDelegate.h"
#import "QCMethod.h"
#import "CustomView.h"
#import "UserImageVC.h"
#import "GroupChatInfoPopOver.h"
#import "PrivateChatUserInfo.h"
#import "DIalogSettingViewController.h"
//#import <mach/mach.h>
#import "OpponentCollectionViewCell.h"
#import "OpponentsFlowLayout.h"
NSString *const kOpponentCollectionViewCellIdentifier = @"OpponentCollectionViewCellIdentifier";



@class QBRTCRemoteVideoView;
@class QBRTCVideoRenderer;
@class QBRTCSampleBufferView;
@class  QBRTCSampleBufferRenderer;
@class QBRTCVideoTrack;
@class QBRTCStatsReport;
@class QBChat;


@interface DialogViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBChatDelegate, QBRTCClientDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>


    // TableView and Cells
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *typingView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (strong,nonatomic) ContentView *handler;
@property (weak, nonatomic) IBOutlet UIView *viewForTableCellFadeEffect;
@property OutgointTableViewCell *outgoingCell;
@property UserIsTypingCell *typingCell;

// UIActions/PopOver/PickerViews
@property UIActionSheet *actionSheet;
@property UIPopoverPresentationController *popOver;
@property (nonatomic, weak) IBOutlet UIImageView * imageView;
@property  UIImagePickerController* pickerController;
@property UIImage *image;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForTableViewFadeEffectTopMargin;

// Image/Date Holder
@property NSDate *sendMessageDate;
@property UIImage *opponentImage;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *navTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *dialogSettings;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;

// MY Views/ Video
@property UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *myScreen;
@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;
@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *opponentsView;
@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *remoteVideoViewOne;
@property (strong, nonatomic) NSMutableDictionary *videoViews;
@property (nonatomic, strong) QBRTCVideoRenderer *renderer;
@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBehindBlur;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visulaEffectBlur;
@property (nonatomic, strong) CAShapeLayer *oval;
@property (nonatomic, strong) CAShapeLayer *oval2;
@property (nonatomic, strong) CAShapeLayer *oval3;
@property BOOL speakersAreOn;

@property UIButton *mainButton;
@property UIButton *menuButtonOne;
@property UIButton *menuButtonTwo;
@property UIButton *menuButtonThree;
@property UIDynamicAnimator *dynamicAnimator;
@property BOOL areButtonsFanned;

@end



@implementation DialogViewController


@synthesize pickerController = _pickerController, delegate = _delegate;



- (void)dealloc {
    self.renderer = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.userDialogs.unreadMessagesCount = 0;

}

- (void)viewDidLoad {

    [super viewDidLoad];


    self.areButtonsFanned = NO;
    self.menuButtonOne.hidden = YES;
    self.menuButtonTwo.hidden = YES;
    self.menuButtonThree.hidden = YES;

    self.view.backgroundColor = [UIColor blackColor];
    self.dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    self.menuButtonOne = [self createButtonWithTitle:@""];
    self.menuButtonTwo = [self createButtonWithTitle:@""];
    self.menuButtonThree = [self createButtonWithTitle:@""];
    self.mainButton = [self createButtonWithTitle:@""];
    [self.mainButton setBackgroundImage:[UIImage imageNamed:@"chatSettingsIcon"] forState:UIControlStateNormal];
    self.mainButton.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];

    [self.menuButtonOne setImage:[UIImage imageNamed:@"dynamicOff"] forState:UIControlStateNormal];
    [self.menuButtonTwo setImage:[UIImage imageNamed:@"micOff"] forState:UIControlStateNormal];
    [self.menuButtonThree setImage:[UIImage imageNamed:@"videoOn"] forState:UIControlStateNormal];

    self.menuButtonOne.hidden = YES;
    self.menuButtonTwo.hidden = YES;
    self.menuButtonThree.hidden = YES;

    [self.menuButtonOne setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1]];
    [self.menuButtonTwo setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1]];
    [self.menuButtonThree setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1]];


    [self.mainButton addTarget:self action:@selector(fanButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtonThree addTarget:self action:@selector(videoButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtonOne addTarget:self action:@selector(speakerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButtonTwo addTarget:self action:@selector(micButton:) forControlEvents:UIControlEventTouchUpInside];

    [[AVAudioSession sharedInstance] setDelegate:self];


    [self.delegate secondViewScreenControllerDidPressCancelButton:self sender:nil];
    
    self.navTitleButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.navTitleButton.layer.shadowOpacity = 0.5;
    self.navTitleButton.layer.shadowRadius = 5;
    self.navTitleButton.layer.shadowOffset = CGSizeMake(5.0f,5.0f);


    self.typingView.backgroundColor = [UIColor clearColor];
    self.typingView.hidden = YES;

    CAShapeLayer * oval = [CAShapeLayer layer];
    oval.frame       = CGRectMake(11.33, 10, 5.31, 5.03);
    oval.fillColor   = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval.strokeColor = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval.path        = [self ovalPath].CGPath;
    [self.typingView.layer addSublayer:oval];
    _oval = oval;

    CAShapeLayer * oval2 = [CAShapeLayer layer];
    oval2.frame       = CGRectMake(27.83, 10, 5.31, 5.03);
    oval2.fillColor   = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval2.strokeColor = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval2.path        = [self oval2Path].CGPath;

    [self.typingView.layer addSublayer:oval2];
    _oval2 = oval2;

    CAShapeLayer * oval3 = [CAShapeLayer layer];
    oval3.frame       = CGRectMake(46.2, 10, 5.31, 5.03);
    oval3.fillColor   = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval3.strokeColor = [UIColor colorWithRed:0.835 green: 0.722 blue:0.188 alpha:1].CGColor;
    oval3.path        = [self oval3Path].CGPath;

    [self.typingView.layer addSublayer:oval3];
    _oval3 = oval3;


    QBChatMessage *messageHistory;

        if([messageHistory markable]){
            [[QBChat instance] readMessage:messageHistory completion:^(NSError * _Nullable error) {
    
            }];
        }

//  SETTING DELEGATES
    self.chatTextView.delegate = self;
    [[QBChat instance] addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    [QBSettings setCarbonsEnabled:YES];
    //    [QBRTCConfig setStatsReportTimeInterval:1.f];
    [QBRTCConfig setDTLSEnabled:YES];





// LOCAL VIDEO SETTINGS
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self.videoCapture startSession];
    }
    QBRTCVideoFormat *videoFormat = [[QBRTCVideoFormat alloc] init];
    videoFormat.frameRate = 30;
    videoFormat.pixelFormat = QBRTCPixelFormat420f;
    videoFormat.width = 640;
    videoFormat.height = 480;

    self.videoCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront];
    self.videoCapture.previewLayer.frame = self.myScreen.bounds;
    [self.videoCapture startSession];
    [self.myScreen.layer insertSublayer:self.videoCapture.previewLayer atIndex:0];

    UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(visualEffectTapped2:)];
    tapRecognizer2.numberOfTapsRequired = 1;
    [self.myScreen addGestureRecognizer:tapRecognizer2];



    self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    self.myScreen.backgroundColor = [UIColor clearColor];
    self.myScreen.layer.borderColor = [UIColor whiteColor].CGColor;
    self.myScreen.layer.borderWidth = 2.0f;
    self.myScreen.layer.cornerRadius = 5.0f;
    self.goBackButton.layer.cornerRadius = 17.0f;
    [self.goBackButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    
//    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];


// FOR TABLEVIEW NOT TO HAVE INSETS
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);

//  INSTANTIATING CUSTOM VIEW THAT ADJUSTS ITSELF TO KEYBOARD SHOR/HIDE
    self.handler = [[ContentView alloc] initWithTextView:self.chatTextView ChatTextViewHeightConstraint:self.chatTextViewHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];

// SETTING THE MINIMUM AND MAXIMUS NUMBER OF LINES FOR THE TEXTVIEW VERTICAL EXPANSION
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];

// GETTING MESSAGE HISTORY
    [self retrievingMessages];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableContentInset:)
                                                 name:@"updateTableContentInset"
                                               object:nil];

//  UI CUSTOM FOR OPONNENT VIDEO VIEWS
    self.remoteVideoViewOne.layer.cornerRadius = 26;
    self.remoteVideoViewOne.layer.masksToBounds = YES;
    self.remoteVideoViewOne.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.remoteVideoViewOne.layer.borderWidth = 0.7;
    self.imageViewBehindBlur.image = self.imageForRightBar;
//    self.imageViewBehindBlur.backgroundColor = [UIColor clearColor];

//  UI CUSTOM FOR TABLE VIEW TEXT VIEW
    self.messageArray = [[NSMutableArray alloc]init];
    self.chatTextView.layer.cornerRadius = 8.f;
    self.chatTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.chatTextView.layer.borderWidth = 0.5f;

    [self.navTitleButton setBackgroundImage:self.imageForRightBar forState:UIControlStateNormal];
    [self.navTitleButton setClipsToBounds:YES];
    self.navTitleButton.layer.cornerRadius = 19.0f;
    [self.navTitleButton setBackgroundColor:[UIColor clearColor]];
    self.navTitleButton.layer.borderColor = [UIColor whiteColor].CGColor;


//  GESTURE RECOGNIZER METHODS FOR ALL
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(visualEffectTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:tapRecognizer];
    [self.dialogSettings addGestureRecognizer:tapRecognizer];
    [self.contentView addGestureRecognizer:tapRecognizer];
    [self.viewForTableCellFadeEffect addGestureRecognizer:tapRecognizer];

//  PAN GESTURE RECOGNIZER
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    [self.remoteVideoViewOne addGestureRecognizer:panGestureRecognizer];

//  DOUBLE TAP GESTURE RECOGNIZER
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    [self.remoteVideoViewOne addGestureRecognizer:doubleTapGestureRecognizer];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;

//  SINGLE TAP GESTURE RECOGNIZER
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.remoteVideoViewOne addGestureRecognizer:singleTapGestureRecognizer];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;



#pragma mark - HANDLING " IS TYPING" STATUS
    __weak typeof(self)weakSelf = self;
    [self.userDialogs setOnUserIsTyping:^(NSUInteger userID) {
        if ([QBSession currentSession].currentUser.ID == userID) {
            return;
        }

        NSString *userString = [@(userID) stringValue];
        [QBRequest sendPushWithText:[[weakSelf senderDisplayName] stringByAppendingString:@" is Live 🎥 "] toUsers:userString successBlock:nil errorBlock:^(QBError *error) {
        }];
        weakSelf.typingView.hidden = NO;
        [self.oval addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
        [self.oval2 addAnimation:[self oval2Animation] forKey:@"oval2Animation"];
        [self.oval3 addAnimation:[self oval3Animation] forKey:@"oval3Animation"];


//        [weakSelf.messageArray addObject:@0];
//
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messageArray.count -1 inSection:0];
//
//        [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];

    // Handling user stopped typing.
    [self.userDialogs setOnUserStoppedTyping:^(NSUInteger userID) {

        weakSelf.typingView.hidden = YES;

//        [weakSelf.messageArray removeObject:@0];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messageArray.count -1 inSection:0];
//        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - Chat Settings Button

- (void)videoButton :(id)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"videoOn"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        [self.session.localMediaStream.videoTrack setEnabled:YES];


    } else {
        [self.session.localMediaStream.videoTrack setEnabled:NO];

        [sender setImage:[UIImage imageNamed:@"videoOff"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

- (void)micButton :(id)sender {
    if ([sender isSelected]) {

        [sender setImage:[UIImage imageNamed:@"micOff"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        [self.session.localMediaStream.audioTrack setEnabled:NO];

    } else {
        [self.session.localMediaStream.audioTrack setEnabled:YES];

        [sender setImage:[UIImage imageNamed:@"micOn"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

- (void)speakerButton :(id)sender {

    if ([sender isSelected]) {
         [self disableSpeakers];
        [sender setImage:[UIImage imageNamed:@"dynamicOff"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [self enableSpeakers];

        [sender setImage:[UIImage imageNamed:@"dynamicOn"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title {

    CGRect frame = self.view.frame;
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(frame.origin.x = 220, frame.origin.y = 20, 50,50)];
    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.layer.borderColor = [[UIColor grayColor]CGColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

- (void)fanIn {

    UISnapBehavior *snapBehavior;
    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonOne snapToPoint:self.mainButton.center];
    [self.dynamicAnimator addBehavior:snapBehavior];

    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonTwo snapToPoint:self.mainButton.center];
    [self.dynamicAnimator addBehavior:snapBehavior];

    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonThree snapToPoint:self.mainButton.center];
    [self.dynamicAnimator addBehavior:snapBehavior];

    [self.menuButtonOne.layer addAnimation:[self ovalAnimationIn] forKey:@"ovalAnimationIn"];
    [self.menuButtonTwo.layer addAnimation:[self ovalAnimationIn] forKey:@"ovalAnimationIn"];
    [self.menuButtonThree.layer addAnimation:[self ovalAnimationIn] forKey:@"ovalAnimationIn"];
}

- (void)fanOut {

    self.menuButtonOne.hidden = NO;
    self.menuButtonTwo.hidden = NO;
    self.menuButtonThree.hidden = NO;

    CGPoint point;
    UISnapBehavior *snapBehavior;

    point = CGPointMake(self.mainButton.frame.origin.x +25, self.mainButton.frame.origin.y + 78);
    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonOne snapToPoint:point];
    [self.dynamicAnimator addBehavior:snapBehavior];

    point = CGPointMake(self.mainButton.frame.origin.x + 25, self.mainButton.frame.origin.y + 130 );
    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonTwo snapToPoint:point];
    [self.dynamicAnimator addBehavior:snapBehavior];

    point = CGPointMake(self.mainButton.frame.origin.x + 25, self.mainButton.frame.origin.y + 182);
    snapBehavior = [[UISnapBehavior alloc]initWithItem:self.menuButtonThree snapToPoint:point];
    [self.dynamicAnimator addBehavior:snapBehavior];

    [self.menuButtonOne.layer addAnimation:[self ovalAnimationOut] forKey:@"ovalAnimationOut"];
    [self.menuButtonTwo.layer addAnimation:[self ovalAnimationOut] forKey:@"ovalAnimationOut"];
    [self.menuButtonThree.layer addAnimation:[self ovalAnimationOut] forKey:@"ovalAnimationOut"];
}

-(void)fanButtons:(id)sender {

    [self.dynamicAnimator removeAllBehaviors];

    if (self.areButtonsFanned) {
        [self fanIn];
    }
    else {
        [self fanOut];
    }
    self.areButtonsFanned = !self.areButtonsFanned;
    if ([sender isSelected]) {
        [sender setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.1]];
        [sender setSelected:NO];
    } else {
        [sender setBackgroundColor:[UIColor colorWithRed:0 green:255 blue:255 alpha:0.2]];
        [self.mainButton.layer addAnimation:[self ovalAnimationOut] forKey:@"ovalAnimationOut"];
        [sender setSelected:YES];
    }
}

// Animation for Chat Settings Button
- (CABasicAnimation*)ovalAnimationIn{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.toValue            = @0;
    opacityAnim.duration           = 0.5;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;
    return opacityAnim;
}

- (CABasicAnimation*)ovalAnimationOut{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.8;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;
    return opacityAnim;
}

#pragma mark - Bezier Path

- (UIBezierPath*)ovalPath{
    UIBezierPath*  ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 10, 10)];
    return ovalPath;
}

- (UIBezierPath*)oval2Path{
    UIBezierPath*  oval2Path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 10, 10)];
    return oval2Path;
}

- (UIBezierPath*)oval3Path{
    UIBezierPath*  oval3Path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 10, 10)];
    return oval3Path;
}

- (CAKeyframeAnimation*)ovalAnimation{CAKeyframeAnimation * opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.values                = @[@0, @1, @0, @0];
    opacityAnim.keyTimes              = @[@0, @0.164, @0.356, @1];
    opacityAnim.duration              = 1;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.repeatCount = 1000;

    return opacityAnim;
}

-(void)enableSpeakers {
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;

    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
}

-(void)disableSpeakers {

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;

    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride
                             );
}

- (CAKeyframeAnimation*)oval2Animation{
    CAKeyframeAnimation * opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.values                = @[@0, @0, @0, @1, @0, @0];
    opacityAnim.keyTimes              = @[@0, @0.022, @0.179, @0.342, @0.54, @1];
    opacityAnim.duration              = 1.02;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.repeatCount = 1000;
    return opacityAnim;
}

- (CAKeyframeAnimation*)oval3Animation{
    CAKeyframeAnimation * opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.values                = @[@0, @0, @1, @0, @0];
    opacityAnim.keyTimes              = @[@0, @0.502, @0.692, @0.888, @1];
    opacityAnim.duration              = 1;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.repeatCount = 1000;
    return opacityAnim;
}

- (NSString *)senderDisplayName {
    return [QBSession currentSession].currentUser.fullName;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];


    [self.session.localMediaStream.audioTrack setEnabled:NO];

    [self scrollTableViewUp];

    // APPLYING GRADINENT EFFECT FOR TABLE VIEW
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.viewForTableCellFadeEffect.bounds;
    gradient.colors = @[(id)[UIColor clearColor].CGColor,
                        (id)[UIColor whiteColor].CGColor,
                        (id)[UIColor whiteColor].CGColor,
                        (id)[UIColor clearColor].CGColor];
    gradient.locations = @[@0.1, @0.5];
    self.viewForTableCellFadeEffect.layer.mask = gradient;
}

// FETCH MESSAGES FROM QUICKBLOX
- (void)retrievingMessages {
    __weak DialogViewController *wSelf = self;
    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:20 skip:0];

    [QBRequest messagesWithDialogID:wSelf.userDialogs.ID extendedRequest:nil forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
        wSelf.messageArray = messages.mutableCopy;
        wSelf.userPhotos = [NSMutableArray arrayWithCapacity:messages.count];


        [wSelf.tableView reloadData];
    } errorBlock:^(QBResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });

        NSLog(@"error: %@", response.error);
    }];
}


#pragma mark - METHOD TO AUTOMATICALLY SCROLL TABLE VIEW DOWN WHEN IT APPEARS
- (void)scrollTableViewUp {
    //SCROLL TO BOTTOM
    double y = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    CGPoint bottomOffset = CGPointMake(0, y);
    NSLog(@"after = %f", y);
    if (y > -self.tableView.contentInset.top)
        [self.tableView setContentOffset:bottomOffset animated:YES];}

#pragma mark -
#pragma mark USER INTERACTION

// RESIGN FIRST RESPONDER WHEN TOUCHED OUTSIDE OF TABLE VIEW
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.tableView isFirstResponder] && [touch view] != self.tableView)
        [self.tableView resignFirstResponder];
    [super touchesBegan:touches withEvent:event];

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    [self scrollTableViewUp];

     if (self.session) {
    self.viewForTableViewFadeEffectTopMargin.constant = 169;
     }
    [self.userDialogs sendUserIsTyping];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.userDialogs sendUserStoppedTyping];
     if (self.session) {
    self.viewForTableViewFadeEffectTopMargin.constant = 300;
     }
//    [self scrollTableViewUp];

    return YES;
}

// ACCESSING CHAT INFO PAGE
- (IBAction)userInfoButtonTapped:(id)sender {

    if (self.userDialogs.type == QBChatDialogTypeGroup) {
        [self performSegueWithIdentifier:@"userInfoPopOverVC" sender:self];

    } else

        [self performSegueWithIdentifier:@"privateChat" sender:self];
}

// DISMISSING DIALOG VIEW CONTROLLER AND HANGING UP THE WEBRTC SESSION
- (IBAction)goBack:(id)sender {
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
//                                                        object:self];
    [self.session hangUp:@{ @"DialogID" : self.userDialogs.ID}];
    [self dismissViewControllerAnimated:YES completion:nil];

}
//
//- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
//    NSString *dialogID = userInfo[@"DialogID"];
//
//       if (session) {
//
//    if (self.userDialogs.ID == dialogID) {
//         [session acceptCall:userInfo];
//        [SVProgressHUD showSuccessWithStatus:@"user accepted call"];
//    } else
//    [session rejectCall:@{@"reject" : @"busy"}];
//
//    [SVProgressHUD showErrorWithStatus:@"user is on anoterh call"];
//
//       }
//}
//SENDING MESSAGE
- (IBAction)sendMessageButton:(id)sender {

    if([self.chatTextView.text length]!=0)
    {
        self.sendMessageButton.enabled = true;

    QBChatMessage *message = [QBChatMessage markableMessage];
    message.text = self.chatTextView.text;
    message.dialogID = self.userDialogs.ID;

    message.senderID = ([QBSession currentSession].currentUser.ID);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];

    __weak DialogViewController *wSelf = self;
    [QBRequest createMessage:message successBlock:^(QBResponse *response, QBChatMessage *createdMessage) {

        [wSelf.messageArray addObject:createdMessage];

        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];

        wSelf.messageToBeUsed = createdMessage;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                            object:self];
        //        wSelf.messageID = createdMessage.ID;
//        [self.outgoingCell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
                                                            object:self];
        [self.tableView reloadData];

        [[QBChat instance] sendSystemMessage:createdMessage completion:^(NSError * _Nullable error) {

        }];

        //SCROLL TO BOTTOM
        double y = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        CGPoint bottomOffset = CGPointMake(0, y);
        NSLog(@"after = %f", y);
        if (y > -self.tableView.contentInset.top)
            [self.tableView setContentOffset:bottomOffset animated:YES];

//        [SVProgressHUD showSuccessWithStatus:@"Sent"];

        NSUInteger userID = createdMessage.recipientID;
        NSString *userString = [NSString stringWithFormat:@"%ld", userID];

        self.chatTextView.text = @"";
        [self.handler textViewDidChange:sender];

        // SEND PUSH NOTIFICATION ALONG WITH CREATED MESSAGE
        [QBRequest sendPushWithText:[[[[self senderDisplayName] stringByAppendingString:@": "] stringByAppendingString:createdMessage.text] mutableCopy] toUsers:userString successBlock:nil errorBlock:^(QBError *error) {
        }];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:[response.error description]];

        NSLog(@"ERROR: %@", response.error);
        }];
    }
}


#pragma mark - UIACTIONSHEET & UIIMAGEPICKERCONTROLLER & IMAGE METHODS

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

    self.imageView.image = image;
    self.imageView.hidden = NO;
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

#pragma mark -
#pragma mark - GESTURE RECOGNIZER METHODS FOR ALL

- (void) moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];

    self.remoteVideoViewOne.center = touchLocation;
}

- (void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    self.remoteVideoViewOne.transform = CGAffineTransformScale(self.remoteVideoViewOne.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);

    pinchGestureRecognizer.view.transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);

    pinchGestureRecognizer.scale = 1.0;
}

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer{

    CGFloat newWidth = 100;
    CGFloat newHeight = 100;
    //    if (self.oponentVIew.frame.size.width == 60.0) {
    //
    //    }
    //    CGPoint currentCenter = self.oponentVIew.center;
    //
    self.remoteVideoViewOne.frame = CGRectMake(self.remoteVideoViewOne.frame.origin.x, self.remoteVideoViewOne.frame.origin.y, newWidth, newHeight);
    //    self.oponentVIew.center = currentCenter;
    self.remoteVideoViewOne.layer.cornerRadius = 50;
}

-(void)doubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer2 {

    [SVProgressHUD showSuccessWithStatus:@"double tap recognized"];

    CGFloat newWidth = 62;
    CGFloat newHeight = 62;

    //    if (self.oponentVIew.frame.size.width == 60.0) {
    //
    //    }
    //    CGPoint currentCenter = self.oponentVIew.center;
    //
    self.remoteVideoViewOne.frame = CGRectMake(self.remoteVideoViewOne.frame.origin.x, self.remoteVideoViewOne.frame.origin.y, newWidth, newHeight);
    //    self.oponentVIew.center = currentCenter;
    self.remoteVideoViewOne.layer.cornerRadius = self.remoteVideoViewOne.layer.cornerRadius;
    self.remoteVideoViewOne.layer.cornerRadius = 31 ;
}

- (void)visualEffectTapped:(UITapGestureRecognizer *)recognizer {
    [self.chatTextView endEditing:YES];
    [self.view resignFirstResponder];
    [self resignFirstResponder];
}
- (void)visualEffectTapped2:(UITapGestureRecognizer *)recognizer2 {
        [self enableSpeakers];
       }

#pragma mark -
#pragma mark UI ANIMATION METHODS
- (CAAnimationGroup*)imageAnimation{

    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.37;

    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];;
    transformAnim.duration           = 0.188;
    transformAnim.autoreverses       = YES;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    CAAnimationGroup *imageAnimGroup   = [CAAnimationGroup animation];
    imageAnimGroup.animations          = @[opacityAnim, transformAnim];
    [imageAnimGroup.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
    imageAnimGroup.fillMode            = kCAFillModeForwards;
    imageAnimGroup.removedOnCompletion = NO;
    imageAnimGroup.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup.animations];

    return imageAnimGroup;
}


    //Animation For ImageView To Minimize the Remote video Received

- (CABasicAnimation*)remoteVideoReceivedImage {
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnim.toValue            = @(0);
    transformAnim.duration           = 0.5;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}
//
//    Animation to imageView when video disconnnected or  ended//

- (CABasicAnimation*)videoEndedImage{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnim.fromValue          = @(0);
    transformAnim.toValue            = @(1);
    transformAnim.duration           = 0.5;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}


//Animation for the Blurr Effect When Video is initiated
- (CABasicAnimation*)remoteVideoStartedBlurr{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @1;
    opacityAnim.toValue            = @0;
    opacityAnim.duration           = 0.7;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    return opacityAnim;
}

//Animation for the Blurr Effect When Video is Ended

- (CABasicAnimation*)videoEndedBlurr{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.5;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    return opacityAnim;
}


#pragma mark -
#pragma mark  TABLE VIEW METHODS

- ( NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.messageArray.count;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [[QBChat instance] addDelegate:self];

    self.chatTextView.delegate = self;

    // CELLS THAT APPEARS WHEN USER STARTS TYPING
//    if ([[self.messageArray objectAtIndex:indexPath.row] isEqual:@0]) {
//        UserIsTypingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useristyping"];
//        cell.backgroundColor = cell.contentView.backgroundColor;
//        [cell.customView startAllAnimations:self];
//
//        return cell;
//    }


    OutgointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"outgoingCell"];

    cell.backgroundColor = cell.contentView.backgroundColor;
    cell.outgoingLabel.frame = CGRectMake(66, 8, 268, 30);


    QBChatMessage *messageHistory = [self.messageArray objectAtIndex:indexPath.row];

    if (messageHistory.senderID == [QBSession currentSession].currentUser.ID) {
        cell.outgoingLabel.text = messageHistory.text;

        messageHistory.markable = true;


        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.doesRelativeDateFormatting = YES;
        NSString *result = [df stringFromDate:messageHistory.createdAt];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *startTimeString = [formatter stringFromDate:messageHistory.createdAt];
        cell.timeLabel.text = startTimeString;

        if ([result isEqualToString:@"Today"]) {
            cell.outgoingMessageTime.text = startTimeString;
            cell.timeLabel.hidden = YES;

        } else {

            NSString *result = [df stringFromDate:messageHistory.createdAt];
            cell.outgoingMessageTime.text = result;
        }
        NSUInteger userProfilePictureID = [QBSession currentSession].currentUser.blobID;
        NSString *privateUrl = [QBCBlob privateUrlForID:userProfilePictureID];

        [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                                 placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                                        }];


        NSInteger sectionsAmount = [self.tableView numberOfSections];
        NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {

            [cell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
            cell.statusIcon.image = [UIImage imageNamed:@"sentIcon"];
        }

        return cell;
    } else {

        IncomingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"incomingCell"];

        cell.incomingLabel.text = messageHistory.text;
        [messageHistory markable];
        cell.backgroundColor = cell.contentView.backgroundColor;

        NSArray *userids = [[NSArray alloc]initWithObjects:@(messageHistory.senderID), nil];
        [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            for (QBUUser *user in users) {

                NSUInteger userProfilePictureID = user.blobID;

                NSString *privateUrl = [QBCBlob privateUrlForID:userProfilePictureID];

                [cell.profileImageincom sd_setImageWithURL:[NSURL URLWithString:privateUrl]
                                     placeholderImage:[UIImage imageNamed:@"Profile Picture"]
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                                            }];
            }
        } errorBlock:^(QBResponse *response) {
        }];

        cell.profileImageincom.image = self.imageForRightBar;


        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.doesRelativeDateFormatting = YES;
        NSString *result = [df stringFromDate:messageHistory.createdAt];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setDateFormat:@"HH:mm a"];
        NSString *startTimeString = [formatter stringFromDate:messageHistory.createdAt];
        cell.timeLabel.text = startTimeString;

        if ([result isEqualToString:@"Today"]) {
            cell.incomingMessageTime.text = startTimeString;
            cell.timeLabel.hidden = YES;
        } else {

            cell.incomingMessageTime.text = result;
        }


        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[self.messageArray objectAtIndex:indexPath.row] isEqual:@0]){
        return 60;
    }
    QBChatMessage *messageHistory = [self.messageArray objectAtIndex:indexPath.row];
    NSString * yourText = messageHistory.text;

    return 25 + [self heightForText:yourText];
}

- (CGFloat)heightForText:(NSString *)text {
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 320, MAX_HEIGHT)];
    textView.text = text;
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (void)updateTableContentInset:(NSNotification *) notification  {
    [self scrollTableViewUp];
}

#pragma mark -
#pragma mark - QBCHAT MESSAGE RECEIVED, DELIVERED, READ DELEGATE METHODS


- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message{
    [[QBChat instance] markAsDelivered:message completion:nil];
    [self.messageArray addObject:message];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
//    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];

}
- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    // the messages comes here from carbons
//    [SVProgressHUD showSuccessWithStatus:@"message was received"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];

    self.outgoingCell.statusIcon.image = [UIImage imageNamed:@"Delivered Image"];


    [[QBChat instance] readMessage:message completion:^(NSError * _Nullable error) {
//        [SVProgressHUD showSuccessWithStatus:@"message was delivered"];
    }];
}
- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID {

//    [SVProgressHUD showSuccessWithStatus:@"message was Read"];

    OutgointTableViewCell *cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSInteger sectionsAmount = [self.tableView numberOfSections];
    NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
    if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {

        [cell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
        cell.statusIcon.image = [UIImage imageNamed:@"readStatus"];

    }
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userId{
//    [SVProgressHUD showSuccessWithStatus:@"message was delivered"];

    OutgointTableViewCell *cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSInteger sectionsAmount = [self.tableView numberOfSections];
    NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
            if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
    
                [cell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
                cell.statusIcon.image = [UIImage imageNamed:@"Delivered Image"];
    
            }
}


#pragma mark -
#pragma mark SEGUES

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userInfoPopOverVC"]) {
        GroupChatInfoPopOver *dvc = segue.destinationViewController;
        UIPopoverPresentationController *controller = dvc.popoverPresentationController;
        controller.permittedArrowDirections = UIPopoverArrowDirectionUp;
        dvc.imageForUserProfileImage = self.imageForRightBar;
        controller.delegate = self;
    }

    else if ([segue.identifier isEqualToString:@"privateChat"]) {
        PrivateChatUserInfo *dvc = segue.destinationViewController;
        dvc.userProfileImage.image = self.imageForRightBar;
        UIPopoverPresentationController *controller = dvc.popoverPresentationController;
        controller.permittedArrowDirections = UIPopoverArrowDirectionUp;
        controller.delegate = self;
        dvc.imageForUserProfileImage = self.imageForRightBar;
    }
}


#pragma mark -
#pragma mark UIVIEWCONTROLLER TRANSITION DELEGATE METHODS

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


#pragma mark -
#pragma mark QBRTCClientDelegate

- (void)setVideoView:(UIView *)videoView {

    if (_videoView != videoView) {
        [_videoView removeFromSuperview];
        _videoView = videoView;
        _videoView.frame = self.opponentsView.bounds;
        [self.opponentsView insertSubview:self.videoView atIndex:1];
    }
}

- (UIView *)videoViewWithOpponentID:(NSNumber *)opponentID {

    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        return nil;
    }

    if (!self.videoViews) {
        self.videoViews = [NSMutableDictionary dictionary];
    }

    id result = self.videoViews[opponentID];

        QBRTCRemoteVideoView *remoteVideoView = nil;

        QBRTCVideoTrack *remoteVideoTrak = [self.session remoteVideoTrackWithUserID:opponentID];

        if (!result && remoteVideoTrak) {

            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:self.view.bounds];
            self.videoViews[opponentID] = remoteVideoView;
            result = remoteVideoView;
        }

        [remoteVideoView setVideoTrack:remoteVideoTrak];

        return result;
    }


- (void)acceptCall {
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];

}

- (NSIndexPath *)indexPathAtUserID:(NSNumber *)userID {

    QBUUser *user = [self userWithID:userID];
    NSUInteger idx = [[Storage instance].users indexOfObject:user];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];

    return indexPath;

}

- (QBUUser *)userWithID:(NSNumber *)userID {

    NSPredicate *userWithIDPredicate = [NSPredicate predicateWithFormat:@"ID == %@", userID];
    return [[[Storage instance].users filteredArrayUsingPredicate:userWithIDPredicate] firstObject];
}
- (void)performUpdateUserID:(NSNumber *)userID block:(void(^)(OpponentCollectionViewCell *cell))block {

    NSIndexPath *indexPath = [self indexPathAtUserID:userID];
    OpponentCollectionViewCell *cell = (id)[self.opponentsCollectionView cellForItemAtIndexPath:indexPath];
    block(cell);
}

//Called in case when receive remote video track from opponent
- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {

    if (session == self.session) {

        _renderer = [[QBRTCSampleBufferRenderer alloc]init];
        QBRTCSampleBufferView *view = (id)self.renderer.rendererView;
        view.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.opponentsView insertSubview:self.renderer.rendererView atIndex:1];


        self.renderer.rendererView.frame = self.opponentsView.bounds;
        self.renderer.rendererView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.renderer setVideoTrack:videoTrack];



//
//        QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];
//
//                [self.opponentsView insertSubview:opponentVideoView atIndex:1];
//
////        if (self.videoView) {
////            [self.opponentsView addSubview:opponentVideoView];
////        }
////        else {
//            [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {
//
//            QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];
////            [cell setVideoView:opponentVideoView];
//             [self setVideoView:opponentVideoView];
//                   }];
//        }
//
    }
}

//#pragma mark - UICollectionViewDataSource
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//
//    return 2
//    ;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//
////    OpponentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
////                                                                                 forIndexPath:indexPath];
////    QBUUser *user = [Storage instance].users[indexPath.row];
////
////    [cell setVideoView:[self videoViewWithOpponentID:@(user.ID)]];
////
////
////    return cell;
////}
//}

-(void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
//    [SVProgressHUD showSuccessWithStatus:@"initialized media stream"];
    self.session.localMediaStream.videoTrack.videoCapture = self.videoCapture;
}


-(void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
//    [SVProgressHUD showSuccessWithStatus:@"accepted By User"];
}


-(void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
//    [SVProgressHUD showSuccessWithStatus:@"hangupBYUser"];
    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 169;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];
}

-(void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"user did not respond"];
}

-(void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
//    [SVProgressHUD showSuccessWithStatus:@"rejected by user"];
}

- (void)session:(QBRTCSession *)session startedConnectingToUser:(NSNumber *)userID {
//    NSLog(@"--------------------Started connecting to user %@", userID);
}

-(void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"Connected to User"];

    [self.imageViewBehindBlur.layer addAnimation:[self remoteVideoReceivedImage] forKey:@"remoteVideoReceivedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self remoteVideoStartedBlurr] forKey:@"RemoteVideoStarted"];

    [self.visulaEffectBlur.layer addAnimation:[self remoteVideoStartedBlurr] forKey:@"RemoteVideoStarted"];
    self.viewForTableViewFadeEffectTopMargin.constant = 300;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];
}

-(void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"Connection Is Closed For User"];
}

-(void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"Connection failed For User"];
}

-(void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"disconnectedbytimeoutfromuser"];
//    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 169;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];

}

-(void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
//    [SVProgressHUD showSuccessWithStatus:@"Disconnected from user"];
//    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 169;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];

}

-(void)sessionDidClose:(QBRTCSession *)session {
//    [SVProgressHUD showSuccessWithStatus:@"session did close"];

    self.session = nil;
    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];

    self.viewForTableViewFadeEffectTopMargin.constant = 169;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];


}
//#pragma Statistic
//
//NSInteger QBRTCGetCpuUsagePercentage() {
//    // Create an array of thread ports for the current task.
//    const task_t task = mach_task_self();
//    thread_act_array_t thread_array;
//    mach_msg_type_number_t thread_count;
//    if (task_threads(task, &thread_array, &thread_count) != KERN_SUCCESS) {
//        return -1;
//    }
//
//    // Sum cpu usage from all threads.
//    float cpu_usage_percentage = 0;
//    thread_basic_info_data_t thread_info_data = {};
//    mach_msg_type_number_t thread_info_count;
//    for (size_t i = 0; i < thread_count; ++i) {
//        thread_info_count = THREAD_BASIC_INFO_COUNT;
//        kern_return_t ret = thread_info(thread_array[i],
//                                        THREAD_BASIC_INFO,
//                                        (thread_info_t)&thread_info_data,
//                                        &thread_info_count);
//        if (ret == KERN_SUCCESS) {
//            cpu_usage_percentage +=
//            100.f * (float)thread_info_data.cpu_usage / TH_USAGE_SCALE;
//        }
//    }
//
//    // Dealloc the created array.
//    vm_deallocate(task, (vm_address_t)thread_array,
//                  sizeof(thread_act_t) * thread_count);
//    return lroundf(cpu_usage_percentage);
//}
//
//#pragma mark - QBRTCClientDelegate
//
//- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
//
//    NSMutableString *result = [NSMutableString string];
//    NSString *systemStatsFormat = @"(cpu)%ld%%\n";
//    [result appendString:[NSString stringWithFormat:systemStatsFormat,
//                          (long)QBRTCGetCpuUsagePercentage()]];
//
//    // Connection stats.
//    NSString *connStatsFormat = @"CN %@ms | %@->%@/%@ | (s)%@ | (r)%@\n";
//    [result appendString:[NSString stringWithFormat:connStatsFormat,
//                          report.connectionRoundTripTime,
//                          report.localCandidateType, report.remoteCandidateType, report.transportType,
//                          report.connectionSendBitrate, report.connectionReceivedBitrate]];
//
//    if (session.conferenceType == QBRTCConferenceTypeVideo) {
//
//        // Video send stats.
//        NSString *videoSendFormat = @"VS (input) %@x%@@%@fps | (sent) %@x%@@%@fps\n"
//        "VS (enc) %@/%@ | (sent) %@/%@ | %@ms | %@\n";
//        [result appendString:[NSString stringWithFormat:videoSendFormat,
//                              report.videoSendInputWidth, report.videoSendInputHeight, report.videoSendInputFps,
//                              report.videoSendWidth, report.videoSendHeight, report.videoSendFps,
//                              report.actualEncodingBitrate, report.targetEncodingBitrate,
//                              report.videoSendBitrate, report.availableSendBandwidth,
//                              report.videoSendEncodeMs,
//                              report.videoSendCodec]];
//
//        // Video receive stats.
//        NSString *videoReceiveFormat =
//        @"VR (recv) %@x%@@%@fps | (decoded)%@ | (output)%@fps | %@/%@ | %@ms\n";
//        [result appendString:[NSString stringWithFormat:videoReceiveFormat,
//                              report.videoReceivedWidth, report.videoReceivedHeight, report.videoReceivedFps,
//                              report.videoReceivedDecodedFps,
//                              report.videoReceivedOutputFps,
//                              report.videoReceivedBitrate, report.availableReceiveBandwidth,
//                              report.videoReceivedDecodeMs]];
//    }
//    // Audio send stats.
//    NSString *audioSendFormat = @"AS %@ | %@\n";
//    [result appendString:[NSString stringWithFormat:audioSendFormat,
//                          report.audioSendBitrate, report.audioSendCodec]];
//
//    // Audio receive stats.
//    NSString *audioReceiveFormat = @"AR %@ | %@ | %@ms | (expandrate)%@";
//    [result appendString:[NSString stringWithFormat:audioReceiveFormat,
//                          report.audioReceivedBitrate, report.audioReceivedCodec, report.audioReceivedCurrentDelay,
//                          report.audioReceivedExpandRate]];
//
//    NSLog(@"---CPU RESULT----%@---- CPU RESULT-----", result);
//}

@end
