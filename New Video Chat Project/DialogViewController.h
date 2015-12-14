//
//  DialogViewController.h
//  
//
//  Created by Edil Ashimov on 11/3/15.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import <QuartzCore/QuartzCore.h>
#import "ContentView.h"

@class QBRTCSession;

@protocol DialogVCDelegate;

@interface DialogViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) id <DialogVCDelegate> delegate;

- (instancetype)initWithPreviewlayer:(AVCaptureVideoPreviewLayer *)layer;

@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property UIImage *imageForRightBar;
@property (weak, nonatomic) IBOutlet UIButton *takePicButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *customNavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@property (strong, nonatomic) NSMutableArray *messageArray;
@property NSString *userFullName;
@property QBChatDialog *userDialogs;
@property NSInteger passedUserId;
@property NSString *passedDialogId;
@property QBChatMessage *messageToBeUsed;

@property (strong, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) IBOutlet UIView *oponentVIew;


-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
-(void)doubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer2;

- (IBAction)expandOrShrinkView:(id)sender;



@end

@protocol DialogVCDelegate  <NSObject>

- (void)localVideoView:(DialogViewController *)localVideoView pressedSwitchButton:(UIButton *)sender;

- (void)reloadTableView;

@end
