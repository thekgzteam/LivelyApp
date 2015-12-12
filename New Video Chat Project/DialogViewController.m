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

#pragma mark - ALL OTHER IMPORTED VIEWS
#import "AppDelegate.h"
#import "QCMethod.h"
#import "CustomView.h"
#import "UserImageVC.h"
#import "GroupChatInfoPopOver.h"
#import "PrivateChatUserInfo.h"
#import "DIalogSettingViewController.h"
#import <mach/mach.h>

@class QBRTCRemoteVideoView;
@class QBRTCVideoTrack;
@class QBRTCStatsReport;

@interface DialogViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBChatDelegate, QBRTCClientDelegate, UIActionSheetDelegate, UIViewControllerTransitioningDelegate, UIPopoverPresentationControllerDelegate>

@property OutgointTableViewCell *outgoingCell;
@property (weak, nonatomic) IBOutlet CustomView *customViewTyping;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIActionSheet *actionSheet;
@property UIPopoverPresentationController *popOver;

@property (nonatomic, weak) IBOutlet UIImageView * imageView;
@property  UIImagePickerController* pickerController;
@property UIImage *image;

@property (weak, nonatomic) IBOutlet UIView *messageContentView;
@property (weak, nonatomic) IBOutlet UIView *viewForTableCellFadeEffect;
@property (weak, nonatomic) IBOutlet UIButton *rightbarButton;
@property NSDate *sendMessageDate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomContraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstrains;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainVideoViewBottomConstraints;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *dialogSettings;


// MY Views
@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;
@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *opponentsView;
@property (nonatomic, weak) QBRTCVideoCapture *capture;


@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;

@property (weak, nonatomic) IBOutlet UIImageView *user2;
@property (weak, nonatomic) IBOutlet UIImageView *user3;

@property (weak, nonatomic) IBOutlet UIButton *navTitleButton;
@property (strong, nonatomic) NSMutableDictionary *videoViews;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBehindBlur;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visulaEffectBlur;




@end

@implementation DialogViewController

@synthesize pickerController = _pickerController;

- (void)dealloc {

}

- (void)viewDidLoad {
    [super viewDidLoad];


    self.MessageInputTextView.delegate = self;
    [[QBChat instance] addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    [QBSettings setCarbonsEnabled:YES];


    [QBRTCConfig setStatsReportTimeInterval:1.f];


    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self.videoCapture startSession];
    }

    //  SETTING CGRECT FOR LOCAL VIDEO
    self.localVideoView.center = CGPointMake(340, 50);
    CGRect frame;
    frame.size.width = 86;
    frame.size.height = 104;
    self.localVideoView.bounds = frame;
    self.videoCapture.previewLayer.frame = frame;

    QBRTCVideoFormat *videoFormat = [[QBRTCVideoFormat alloc] init];
    videoFormat.frameRate = 30;
    videoFormat.pixelFormat = QBRTCPixelFormat420f;
    videoFormat.width = 640;
    videoFormat.height = 480;

    self.videoCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront];
    self.videoCapture.previewLayer.frame = self.localVideoView.frame;
    [self.videoCapture startSession];
    [self.localVideoView.layer insertSublayer:self.videoCapture.previewLayer atIndex:0];
    self.localVideoView.backgroundColor = [UIColor clearColor];

    [QBRTCConfig setDTLSEnabled:YES];

    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];

    // GETTING MESSAGE HISTORY
    [self retrievingMessages];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTableContentInset:)
                                                 name:@"updateTableContentInset"
                                               object:nil];

    // UI CUSTOMIZATION
    [self.rightbarButton setBackgroundImage:self.imageForRightBar forState:UIControlStateNormal];
    [self.rightbarButton setFrame:CGRectMake(300, 27, 39, 39)];
    [self.rightbarButton setClipsToBounds:YES];
    self.rightbarButton.layer.cornerRadius = 19.0f;
    [self.dialogSettings setFrame:CGRectMake(260, 27, 43, 39)];
    self.sendMessageButton.enabled = false;

    self.imageViewBehindBlur.image = self.imageForRightBar;
    self.imageViewBehindBlur.backgroundColor = [UIColor clearColor];


    [self reloaCells];


    //UI CUSTOM FOR OPONNENT VIDEO VIEWS
   
    self.user2.layer.cornerRadius = 30;
    self.user2.layer.masksToBounds = YES;
    self.user2.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.user2.layer.borderWidth = 0.7;
    self.user2.hidden = YES;

    self.user3.layer.cornerRadius = 30;
    self.user3.layer.masksToBounds = YES;
    self.user3.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.user3.layer.borderWidth = 0.7;
    self.user3.hidden = YES;

    self.oponentVIew.layer.cornerRadius = 26;
    self.oponentVIew.layer.masksToBounds = YES;
    self.oponentVIew.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.oponentVIew.layer.borderWidth = 0.7;


    // UI CUSTOM FOR TABLE VIEW TEXT VIEW
    self.messageArray = [[NSMutableArray alloc]init];
    self.MessageInputTextView.layer.cornerRadius = 8.f;
    self.MessageInputTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.MessageInputTextView.layer.borderWidth = 0.5f;
    [self.navTitleButton setTitle:self.userFullName forState:UIControlStateNormal];

    // GESTURE RECOGNIZER METHODS FOR ALL
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(visualEffectTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.tableView addGestureRecognizer:tapRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.oponentVIew addGestureRecognizer:panGestureRecognizer];

    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.oponentVIew addGestureRecognizer:pinchGestureRecognizer];

    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    [self.oponentVIew addGestureRecognizer:doubleTapGestureRecognizer];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;

    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.oponentVIew addGestureRecognizer:singleTapGestureRecognizer];
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
    }];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
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

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.MessageInputTextView  sizeToFit];
    [self.MessageInputTextView layoutIfNeeded];

}

// FETCH MESSAGES FROM QUICKBLOX
- (void)retrievingMessages {
    __weak DialogViewController *wSelf = self;
    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:20 skip:0];

    [QBRequest messagesWithDialogID:self.userDialogs.ID extendedRequest:nil forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
        wSelf.messageArray = messages.mutableCopy;
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
    double y = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    CGPoint bottomOffset = CGPointMake(0, y);

    if (y > -self.tableView.contentInset.top)
        [self.tableView setContentOffset:bottomOffset animated:YES];
    [self.tableView reloadData];
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

    [self.userDialogs sendUserIsTyping];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.userDialogs sendUserStoppedTyping];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    [self.messageContentView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.1 animations:^{
        [self.messageContentView updateConstraintsIfNeeded];
    }];
}

- (CGFloat)textViewHeightForAttributedText: (NSAttributedString *)text andWidth: (CGFloat)width {

    [self.MessageInputTextView setAttributedText:text];
    return 40 + [self heightForText:self.MessageInputTextView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if (![self.MessageInputTextView.text isEqualToString:@""]) {
        self.sendMessageButton.enabled = true;
    } else if ([self.MessageInputTextView.text isEqualToString:@""]) {
        self.sendMessageButton.enabled = false;
    }

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    [self scrollTableViewUp];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentViewBottom.constant = 215;
        self.sendButtonBottom.constant = 220;
        self.takePhotoBottom.constant = 195;
        self.textViewBottom.constant = 220;
        self.tableViewTopConstrains.constant = 160;
    }
                     completion:^(BOOL finished) {
                     }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    [UIView animateWithDuration:0.3 animations:^{
        self.contentViewBottom.constant = 0;

        self.sendButtonBottom.constant = 5;
        self.takePhotoBottom.constant = -18;
        self.textViewBottom.constant = 5;
        self.tableViewTopConstrains.constant = 355;

    }
                     completion:^(BOOL finished) {
                     }];
}

// ACCESSING CHAT INFO PROFILE IMAGE
- (IBAction)onRightBarButtonPressed:(id)sender {

    UserImageVC *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserImageVC"];
    dvc.transitioningDelegate = self;
    dvc.modalPresentationStyle = UIModalPresentationCustom;
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
    [self.session hangUp:@{@"key" : @"value"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//SENDING MESSAGE
- (IBAction)sendMessageButton:(id)sender {

    self.customViewTyping.hidden = YES;

    if ([self.MessageInputTextView.text isEqualToString:@""]) {
        self.sendMessageButton.enabled = false;
    } else
        self.sendMessageButton.enabled = true;

    QBChatMessage *message = [QBChatMessage message];
    message.text = self.MessageInputTextView.text;
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

        self.MessageInputTextView.text = @"";

        // SEND PUSH NOTIFICATION ALONG WITH CREATED MESSAGE
        [QBRequest sendPushWithText:[[[[self senderDisplayName] stringByAppendingString:@": "] stringByAppendingString:createdMessage.text] mutableCopy] toUsers:userString successBlock:nil errorBlock:^(QBError *error) {
        }];
    } errorBlock:^(QBResponse *response) {
        [SVProgressHUD showErrorWithStatus:[response.error description]];

        NSLog(@"ERROR: %@", response.error);
    }];

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
    CGPoint touchLocation = [panGestureRecognizer locationInView:self.remoteVideoView];

    self.oponentVIew.center = touchLocation;
}

- (void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    self.oponentVIew.transform = CGAffineTransformScale(self.oponentVIew.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);

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
    self.oponentVIew.frame = CGRectMake(self.oponentVIew.frame.origin.x, self.oponentVIew.frame.origin.y, newWidth, newHeight);
    //    self.oponentVIew.center = currentCenter;
    self.oponentVIew.layer.cornerRadius = 50;
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
    self.oponentVIew.frame = CGRectMake(self.oponentVIew.frame.origin.x, self.oponentVIew.frame.origin.y, newWidth, newHeight);
    //    self.oponentVIew.center = currentCenter;
    self.oponentVIew.layer.cornerRadius = self.oponentVIew.layer.cornerRadius;
    self.oponentVIew.layer.cornerRadius = 31 ;
}

- (void)visualEffectTapped:(UITapGestureRecognizer *)recognizer {
    [self.MessageInputTextView endEditing:YES];
}

- (IBAction)rejectButton:(id)sender {
    [self.session rejectCall:nil];
}
- (IBAction)temporaryAcceptCallButton:(id)sender {
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];

    [SVProgressHUD showSuccessWithStatus:@"Trying to accept the call"];

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



#pragma mark -
#pragma mark  TABLE VIEW METHODS

- ( NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // CELLS THAT APPEARS WHEN USER STARTS TYPING
    if ([[self.messageArray objectAtIndex:indexPath.row] isEqual:@0]) {
        UserIsTypingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"useristyping"];
        return cell;
    }

    OutgointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"outgoingCell"];

    cell.outgoingLabel.frame = CGRectMake(66, 8, 268, 30);

    QBChatMessage *messageHistory = [self.messageArray objectAtIndex:indexPath.row];

    if (messageHistory.senderID == [QBSession currentSession].currentUser.ID) {
        cell.outgoingLabel.text = messageHistory.text;


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
        NSArray *userids = [[NSArray alloc]initWithObjects:@(messageHistory.senderID), nil];
        [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            for (QBUUser *user in users) {
                NSUInteger userProfilePictureID = user.blobID;

                [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {

                    // Here we use the new provided sd_setImageWithURL: method to load the web image
                    //                    [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
                    //                                      placeholderImage:[UIImage imageWithData:fileData]];

                    cell.profileImage.image = [UIImage imageWithData:fileData];

                } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                    nil;
                } errorBlock:^(QBResponse * _Nonnull response) {
                }];
            }

        } errorBlock:^(QBResponse *response) {
            // Handle error here
        }];

        cell.chosenImage.image = self.imageView.image;

        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {

            [cell.statusIcon.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
            cell.statusIcon.image = [UIImage imageNamed:@"sentIcon"];

        }
        return cell;
    } else {

        IncomingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"incomingCell"];
        cell.incomingLabel.text = messageHistory.text;

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
        return 38;
    }
    QBChatMessage *messageHistory = [self.messageArray objectAtIndex:indexPath.row];
    NSString * yourText = messageHistory.text;

    return 20 + [self heightForText:yourText];
}

- (CGFloat)heightForText:(NSString *)text {
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 320, MAX_HEIGHT)];
    textView.text = text;
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (void)updateTableContentInset:(NSNotification *) notification  {

    //    [self.tableView reloadData];
    //    [self.tableView beginUpdates];
    //        NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]];//
    //        [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    //        [self.tableView endUpdates];
    [SVProgressHUD showSuccessWithStatus:@"adding new cell to tableView"];
}

-  (void)reloaCells {
    NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat contentInsetTop = self.tableView.bounds.size.height;
    for (NSInteger i = 0; i < numRows; i++) {
        contentInsetTop -= [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (contentInsetTop <= 0) {
            contentInsetTop = 0;
            break;
        }
    }
    self.tableView.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0);
    self.messageArray = self.messageArray.reverseObjectEnumerator.allObjects;
}

- (NSString *)senderDisplayName {
    return [QBSession currentSession].currentUser.fullName;
}

#pragma mark -
#pragma mark - QBCHAT MESSAGE RECEIVED, DELIVERED, READ DELEGATE METHODS


- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message{
    [SVProgressHUD showSuccessWithStatus:@"system received message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableContentInset"
                                                        object:self];
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
    dialogID = self.userDialogs.ID;

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


- (UIView *)videoViewWithOpponentID:(NSNumber *)opponentID {

    if (self.session.conferenceType == QBRTCConferenceTypeAudio) {
        return nil;
    }

    if (!self.videoViews) {
        self.videoViews = [NSMutableDictionary dictionary];
    }

    id result = self.videoViews[opponentID];

    if ([QBSession currentSession].currentUser.ID == opponentID.integerValue) {//Local preview

        QBRTCRemoteVideoView *remoteVideoView = nil;

        QBRTCVideoTrack *remoteVideoTrak = [self.session remoteVideoTrackWithUserID:opponentID];

        if (!result && remoteVideoTrak) {

            remoteVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:self.localVideoView.bounds];
            self.videoViews[opponentID] = remoteVideoView;
            result = remoteVideoView;
        }

        [remoteVideoView setVideoTrack:remoteVideoTrak];

        return result;
    }

    return result;
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



- (void)acceptCall {
    NSDictionary *userInfo = @{@"acceptCall" : @"userInfo"};
    [self.session acceptCall:userInfo];
}

//Called in case when receive remote video track from opponent
- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"received a remote videotrack from user"];

    self.opponentsView.backgroundColor = [UIColor greenColor];
    [self.opponentsView setVideoTrack:videoTrack];

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
}

-(void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Connection Is Closed For User"];
}

-(void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Connection failed For User"];
}

-(void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"disconnectedbytimeoutfromuser"];
}

-(void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    [SVProgressHUD showSuccessWithStatus:@"Disconnected from user"];
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
