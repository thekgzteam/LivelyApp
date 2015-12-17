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


#pragma mark - ALL OTHER IMPORTED VIEWS
#import "AppDelegate.h"
#import "QCMethod.h"
#import "CustomView.h"
#import "UserImageVC.h"
#import "GroupChatInfoPopOver.h"
#import "PrivateChatUserInfo.h"
#import "DIalogSettingViewController.h"
#import <mach/mach.h>
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
@interface DialogViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBChatDelegate, QBRTCClientDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *opponentsCollectionView;
@property OutgointTableViewCell *outgoingCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIActionSheet *actionSheet;
@property UIPopoverPresentationController *popOver;

@property (nonatomic, weak) IBOutlet UIImageView * imageView;
@property  UIImagePickerController* pickerController;
@property UIImage *image;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property UserIsTypingCell *typingCell;

@property (strong,nonatomic) ContentView *handler;
@property (weak, nonatomic) IBOutlet UIView *viewForTableCellFadeEffect;
@property (weak, nonatomic) IBOutlet UIButton *rightbarButton;
@property NSDate *sendMessageDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForTableViewFadeEffectTopMargin;

@property (weak, nonatomic) IBOutlet UIButton *dialogSettings;


// MY Views
@property (weak, nonatomic) IBOutlet UIView *myScreen;
@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;
@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *opponentsView;
@property UIView *videoView;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *remoteVideoViewOne;

@property (strong, nonatomic) NSMutableDictionary *videoViews;



@property (weak, nonatomic) IBOutlet UIButton *navTitleButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBehindBlur;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visulaEffectBlur;




@end

@implementation DialogViewController

@synthesize pickerController = _pickerController;

- (void)dealloc {

}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
  }

- (void)viewDidLoad {
    [super viewDidLoad];

    // for table View not to have Inset space from top
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);


    self.chatTextView.delegate = self;
    [[QBChat instance] addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    [QBSettings setCarbonsEnabled:YES];
    [QBRTCConfig setStatsReportTimeInterval:1.f];


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

    self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.myScreen.backgroundColor = [UIColor clearColor];
    self.myScreen.layer.borderColor = [UIColor whiteColor].CGColor;
    self.myScreen.layer.borderWidth = 2.0f;
    self.myScreen.layer.cornerRadius = 5.0f;

    [QBRTCConfig setDTLSEnabled:YES];

    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];

    //Instantiating custom view that adjusts itself to keyboard show/hide
    self.handler = [[ContentView alloc] initWithTextView:self.chatTextView ChatTextViewHeightConstraint:self.chatTextViewHeightConstraint contentView:self.contentView ContentViewHeightConstraint:self.contentViewHeightConstraint andContentViewBottomConstraint:self.contentViewBottomConstraint];


    //Setting the minimum and maximum number of lines for the textview vertical expansion
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:3];

    // GETTING MESSAGE HISTORY
    [self retrievingMessages];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableContentInset:)
                                                 name:@"updateTableContentInset"
                                               object:nil];


    self.imageViewBehindBlur.image = self.imageForRightBar;
    self.imageViewBehindBlur.backgroundColor = [UIColor clearColor];




    //UI CUSTOM FOR OPONNENT VIDEO VIEWS


    self.remoteVideoViewOne.layer.cornerRadius = 26;
    self.remoteVideoViewOne.layer.masksToBounds = YES;
    self.remoteVideoViewOne.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.remoteVideoViewOne.layer.borderWidth = 0.7;



    // UI CUSTOM FOR TABLE VIEW TEXT VIEW
    self.messageArray = [[NSMutableArray alloc]init];
    self.chatTextView.layer.cornerRadius = 8.f;
    self.chatTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.chatTextView.layer.borderWidth = 0.5f;

    [self.navTitleButton setBackgroundImage:self.imageForRightBar forState:UIControlStateNormal];
    [self.navTitleButton setClipsToBounds:YES];
    self.navTitleButton.layer.cornerRadius = 19.0f;
    [self.navTitleButton setBackgroundColor:[UIColor clearColor]];
    self.navTitleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.navTitleButton.layer.borderWidth = 0.5f;


    // GESTURE RECOGNIZER METHODS FOR ALL
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(visualEffectTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:tapRecognizer];
    [self.opponentsView addGestureRecognizer:tapRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    panGestureRecognizer.cancelsTouchesInView = NO;
    [self.remoteVideoViewOne addGestureRecognizer:panGestureRecognizer];

//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
//    [self.remoteVideoViewOne addGestureRecognizer:pinchGestureRecognizer];

    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    [self.remoteVideoViewOne addGestureRecognizer:doubleTapGestureRecognizer];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;

    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.remoteVideoViewOne addGestureRecognizer:singleTapGestureRecognizer];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;



#pragma mark - HANDLING " IS TYPING" STATUS
    __weak typeof(self)weakSelf = self;
    [self.userDialogs setOnUserIsTyping:^(NSUInteger userID) {
        if ([QBSession currentSession].currentUser.ID == userID) {
            return;
        }

        [SVProgressHUD showSuccessWithStatus:@"user started typing"];
        [weakSelf.messageArray addObject:@0];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messageArray.count -1 inSection:0];

        [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];


    }];

    // Handling user stopped typing.
    [self.userDialogs setOnUserStoppedTyping:^(NSUInteger userID) {
        [SVProgressHUD showSuccessWithStatus:@"stopped typing"];

        [weakSelf.messageArray removeObject:@0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messageArray.count inSection:0];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [weakSelf.tableView reloadData];
    }];
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

[self.navigationController setNavigationBarHidden:NO];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

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

    [QBRequest messagesWithDialogID:self.userDialogs.ID extendedRequest:nil forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
        wSelf.messageArray = messages.mutableCopy;
        wSelf.userPhotos = [NSMutableArray arrayWithCapacity:messages.count];

        for (id o in messages) {
            [wSelf.userPhotos addObject:[NSNull null]];
        }

        [wSelf.tableView reloadData];
    } errorBlock:^(QBResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });

        [SVProgressHUD showErrorWithStatus:@"error getting messages"];
        NSLog(@"error: %@", response.error);
    }];
}

#pragma mark - METHOD TO AUTOMATICALLY SCROLL TABLE VIEW DOWN WHEN IT APPEARS
- (void)scrollTableViewUp {
    //Always scroll the chat table when the user sends the message
    if([self.tableView numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

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
    [self.userDialogs sendUserIsTyping];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.userDialogs sendUserStoppedTyping];

    [self scrollTableViewUp];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {


    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}

// ACCESSING CHAT INFO PROFILE IMAGE
- (IBAction)onRightBarButtonPressed:(id)sender {

    UserImageVC *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserImageVC"];
    dvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    dvc.imageForUserImage = self.imageForRightBar;
    [self presentViewController:dvc animated:YES completion:nil];

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

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
                                                        object:self];

    [self.session hangUp:@{ @"DialogID" : self.userDialogs.ID}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//SENDING MESSAGE
- (IBAction)sendMessageButton:(id)sender {


    if([self.chatTextView.text length]!=0)
    {
        self.sendMessageButton.enabled = true;

    QBChatMessage *message = [QBChatMessage message];
    message.text = self.chatTextView.text;
    message.dialogID = self.userDialogs.ID;

    message.senderID = ([QBSession currentSession].currentUser.ID);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];

    __weak DialogViewController *wSelf = self;
    [QBRequest createMessage:message successBlock:^(QBResponse *response, QBChatMessage *createdMessage) {


        [wSelf.messageArray addObject:createdMessage];
        wSelf.messageToBeUsed = createdMessage;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                            object:self];
        //        wSelf.messageID = createdMessage.ID;
        [self.outgoingCell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];

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

        [SVProgressHUD showSuccessWithStatus:@"Sent"];

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
}


- (IBAction)onSettingsButtonPressed:(id)sender {
    DIalogSettingViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DIalogSettingsVC"];
    dvc.transitioningDelegate = self;
    dvc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:dvc animated:YES completion:nil];
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

- (CAAnimationGroup*)animationForSettingsButton{

    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.37;

    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];;
    transformAnim.duration           = 0.188;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    CAAnimationGroup *imageAnimGroup2   = [CAAnimationGroup animation];
    imageAnimGroup2.animations          = @[opacityAnim, transformAnim];
    [imageAnimGroup2.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
    imageAnimGroup2.fillMode            = kCAFillModeForwards;
    imageAnimGroup2.removedOnCompletion = NO;
    imageAnimGroup2.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup2.animations];

    return imageAnimGroup2;
}

- (CAAnimationGroup*)animationForSettingsButton2{

    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @0;
    opacityAnim.duration           = 0.37;

    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 0)];;
    transformAnim.duration           = 0.188;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    CAAnimationGroup *imageAnimGroup3   = [CAAnimationGroup animation];
    imageAnimGroup3.animations          = @[opacityAnim, transformAnim];
    [imageAnimGroup3.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
    imageAnimGroup3.fillMode            = kCAFillModeForwards;
    imageAnimGroup3.removedOnCompletion = NO;
    imageAnimGroup3.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup3.animations];

    return imageAnimGroup3;
}

    //Animation For ImageView To Minimize the Remote video Received

- (CABasicAnimation*)remoteVideoReceivedImage {
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnim.toValue            = @(0);
    transformAnim.duration           = 0.7;
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
    transformAnim.duration           = 1.5;
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
    opacityAnim.duration           = 1.5;
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
    if ([[self.messageArray objectAtIndex:indexPath.row] isEqual:@0]) {
        UserIsTypingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useristyping"];
        cell.backgroundColor = cell.contentView.backgroundColor;
        [cell.customView startAllAnimations:self];

        return cell;
    }

    OutgointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"outgoingCell"];
    cell.backgroundColor = cell.contentView.backgroundColor;
    cell.outgoingLabel.frame = CGRectMake(66, 8, 268, 30);
    UIImage *photo = [self.userPhotos objectAtIndex:indexPath.row];


    QBChatMessage *messageHistory = [self.messageArray objectAtIndex:indexPath.row];

    if (messageHistory.senderID == [QBSession currentSession].currentUser.ID) {
        cell.outgoingLabel.text = messageHistory.text;

        messageHistory.markable = true;
        // sends 'read' status back
        if([messageHistory markable]){
            [[QBChat instance] readMessage:messageHistory completion:^(NSError * _Nullable error) {

            }];
        }

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.doesRelativeDateFormatting = YES;
        NSString *result = [df stringFromDate:messageHistory.createdAt];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *startTimeString = [formatter stringFromDate:messageHistory.createdAt];

        if ([result isEqualToString:@"Today"]) {
            cell.outgoingMessageTime.text = startTimeString;


        } else {

            NSString *result = [df stringFromDate:messageHistory.createdAt];
            cell.outgoingMessageTime.text = result;
        }

                    if (![photo isEqual:[NSNull null]]) {
                        cell.profileImage.image = photo;
                    } else {

        NSArray *userids = [[NSArray alloc]initWithObjects:@(messageHistory.senderID), nil];
        [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            for (QBUUser *user in users) {
                NSUInteger userProfilePictureID = user.blobID;

                [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
                    UIImage *userImage = [UIImage imageWithData:fileData];

                        if (userImage == nil) {
                             [self.userPhotos insertObject:[UIImage imageNamed:@"Profile Picture"] atIndex:indexPath.row];
    
                        } else {
    
                            [self.userPhotos insertObject:userImage atIndex:indexPath.row];
                        }
    
                        cell.profileImage.image = [self.userPhotos objectAtIndex:indexPath.row];

//                    cell.profileImage.image = [UIImage imageWithData:fileData];

                } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                    nil;
                } errorBlock:^(QBResponse * _Nonnull response) {
                }];
            }

        } errorBlock:^(QBResponse *response) {
            // Handle error here
        }];
                    }
        cell.chosenImage.image = self.imageView.image;

        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
//        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
//
//            [cell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
//            cell.statusIcon.image = [UIImage imageNamed:@"sentIcon"];
//
//        }
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

                [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {

                    // Here we use the new provided sd_setImageWithURL: method to load the web image
                    //                    [cell.profileImageincom sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
                    //                                      placeholderImage:[UIImage imageWithData:fileData]];

                    cell.profileImageincom.image = [UIImage imageWithData:fileData];


                } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                    nil;
                } errorBlock:^(QBResponse * _Nonnull response) {
                }];
            }

        } errorBlock:^(QBResponse *response) {
            // Handle error here
        }];



        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.doesRelativeDateFormatting = YES;
        NSString *result = [df stringFromDate:messageHistory.createdAt];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *startTimeString = [formatter stringFromDate:messageHistory.createdAt];

        if ([result isEqualToString:@"Today"]) {
            cell.incomingMessageTime.text = startTimeString;

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
    [SVProgressHUD showSuccessWithStatus:@"adding new cell to tableView"];
}

- (NSString *)senderDisplayName {
    return [QBSession currentSession].currentUser.fullName;
}

#pragma mark -
#pragma mark - QBCHAT MESSAGE RECEIVED, DELIVERED, READ DELEGATE METHODS


- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message{

    [self.messageArray addObject:message];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count -1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [SVProgressHUD showSuccessWithStatus:@"system received message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];


//    message.markable = true;
//    // sends 'read' status back
//    if([message markable]){
//        [[QBChat instance] readMessage:message completion:^(NSError * _Nullable error) {
//
//        }];
//    }

}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    // the messages comes here from carbons
    [SVProgressHUD showSuccessWithStatus:@"message was received"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];

    self.outgoingCell.statusIcon.image = [UIImage imageNamed:@"Delivered Image"];


    [[QBChat instance] readMessage:message completion:^(NSError * _Nullable error) {
        [SVProgressHUD showSuccessWithStatus:@"message was delivered"];
    }];
}
- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID {

    self.outgoingCell.statusIcon.image = [UIImage imageNamed:@"readStatus"];

    [SVProgressHUD showSuccessWithStatus:@"message was read"];
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

        QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];

//                [self.opponentsView insertSubview:opponentVideoView atIndex:1];

//        if (self.videoView) {
//            [self.opponentsView addSubview:opponentVideoView];
//        }
//        else {
            [self performUpdateUserID:userID block:^(OpponentCollectionViewCell *cell) {

            QBRTCRemoteVideoView *opponentVideoView = (id)[self videoViewWithOpponentID:userID];
            [cell setVideoView:opponentVideoView];
             [self setVideoView:opponentVideoView];
                   }];
        }

    }


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 2
    ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    OpponentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOpponentCollectionViewCellIdentifier
                                                                                 forIndexPath:indexPath];
    QBUUser *user = [Storage instance].users[indexPath.row];

    [cell setVideoView:[self videoViewWithOpponentID:@(user.ID)]];


    return cell;
}


-(void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    [SVProgressHUD showSuccessWithStatus:@"initialized media stream"];
    self.session.localMediaStream.videoTrack.videoCapture = self.videoCapture;

}

-(void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
    [SVProgressHUD showSuccessWithStatus:@"accepted By User"];
}

-(void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    [SVProgressHUD showSuccessWithStatus:@"hangupBYUser"];
    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 250;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];

}

-(void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"user did not respond"];
}

-(void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    [SVProgressHUD showSuccessWithStatus:@"rejected by user"];
}

- (void)session:(QBRTCSession *)session startedConnectingToUser:(NSNumber *)userID {
    NSLog(@"--------------------Started connecting to user %@", userID);
}

-(void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Connected to User"];

    [self.imageViewBehindBlur.layer addAnimation:[self remoteVideoReceivedImage] forKey:@"remoteVideoReceivedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self remoteVideoStartedBlurr] forKey:@"RemoteVideoStarted"];

    [self.visulaEffectBlur.layer addAnimation:[self remoteVideoStartedBlurr] forKey:@"RemoteVideoStarted"];
    self.viewForTableViewFadeEffectTopMargin.constant = 400;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];
}

-(void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Connection Is Closed For User"];
}

-(void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Connection failed For User"];
}

-(void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"disconnectedbytimeoutfromuser"];
//    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 250;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];

}

-(void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Disconnected from user"];
//    [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];
    self.viewForTableViewFadeEffectTopMargin.constant = 250;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];

}

-(void)sessionDidClose:(QBRTCSession *)session {
    [SVProgressHUD showSuccessWithStatus:@"session did close"];

    self.session = nil;
        [self.imageViewBehindBlur.layer addAnimation:[self videoEndedImage] forKey:@"videoEndedImage"];
    [self.visulaEffectBlur.layer addAnimation:[self videoEndedBlurr] forKey:@"videoEndedBlurr"];

    self.viewForTableViewFadeEffectTopMargin.constant = 250;
    [UIView animateWithDuration:1.0 animations:^{
        [self.viewForTableCellFadeEffect layoutIfNeeded];
    }];


}
#pragma Statistic

NSInteger QBRTCGetCpuUsagePercentage() {
    // Create an array of thread ports for the current task.
    const task_t task = mach_task_self();
    thread_act_array_t thread_array;
    mach_msg_type_number_t thread_count;
    if (task_threads(task, &thread_array, &thread_count) != KERN_SUCCESS) {
        return -1;
    }

    // Sum cpu usage from all threads.
    float cpu_usage_percentage = 0;
    thread_basic_info_data_t thread_info_data = {};
    mach_msg_type_number_t thread_info_count;
    for (size_t i = 0; i < thread_count; ++i) {
        thread_info_count = THREAD_BASIC_INFO_COUNT;
        kern_return_t ret = thread_info(thread_array[i],
                                        THREAD_BASIC_INFO,
                                        (thread_info_t)&thread_info_data,
                                        &thread_info_count);
        if (ret == KERN_SUCCESS) {
            cpu_usage_percentage +=
            100.f * (float)thread_info_data.cpu_usage / TH_USAGE_SCALE;
        }
    }

    // Dealloc the created array.
    vm_deallocate(task, (vm_address_t)thread_array,
                  sizeof(thread_act_t) * thread_count);
    return lroundf(cpu_usage_percentage);
}

#pragma mark - QBRTCClientDelegate

- (void)session:(QBRTCSession *)session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {

    NSMutableString *result = [NSMutableString string];
    NSString *systemStatsFormat = @"(cpu)%ld%%\n";
    [result appendString:[NSString stringWithFormat:systemStatsFormat,
                          (long)QBRTCGetCpuUsagePercentage()]];

    // Connection stats.
    NSString *connStatsFormat = @"CN %@ms | %@->%@/%@ | (s)%@ | (r)%@\n";
    [result appendString:[NSString stringWithFormat:connStatsFormat,
                          report.connectionRoundTripTime,
                          report.localCandidateType, report.remoteCandidateType, report.transportType,
                          report.connectionSendBitrate, report.connectionReceivedBitrate]];

    if (session.conferenceType == QBRTCConferenceTypeVideo) {

        // Video send stats.
        NSString *videoSendFormat = @"VS (input) %@x%@@%@fps | (sent) %@x%@@%@fps\n"
        "VS (enc) %@/%@ | (sent) %@/%@ | %@ms | %@\n";
        [result appendString:[NSString stringWithFormat:videoSendFormat,
                              report.videoSendInputWidth, report.videoSendInputHeight, report.videoSendInputFps,
                              report.videoSendWidth, report.videoSendHeight, report.videoSendFps,
                              report.actualEncodingBitrate, report.targetEncodingBitrate,
                              report.videoSendBitrate, report.availableSendBandwidth,
                              report.videoSendEncodeMs,
                              report.videoSendCodec]];

        // Video receive stats.
        NSString *videoReceiveFormat =
        @"VR (recv) %@x%@@%@fps | (decoded)%@ | (output)%@fps | %@/%@ | %@ms\n";
        [result appendString:[NSString stringWithFormat:videoReceiveFormat,
                              report.videoReceivedWidth, report.videoReceivedHeight, report.videoReceivedFps,
                              report.videoReceivedDecodedFps,
                              report.videoReceivedOutputFps,
                              report.videoReceivedBitrate, report.availableReceiveBandwidth,
                              report.videoReceivedDecodeMs]];
    }
    // Audio send stats.
    NSString *audioSendFormat = @"AS %@ | %@\n";
    [result appendString:[NSString stringWithFormat:audioSendFormat,
                          report.audioSendBitrate, report.audioSendCodec]];

    // Audio receive stats.
    NSString *audioReceiveFormat = @"AR %@ | %@ | %@ms | (expandrate)%@";
    [result appendString:[NSString stringWithFormat:audioReceiveFormat,
                          report.audioReceivedBitrate, report.audioReceivedCodec, report.audioReceivedCurrentDelay,
                          report.audioReceivedExpandRate]];

    NSLog(@"---CPU RESULT----%@---- CPU RESULT-----", result);
}

@end
