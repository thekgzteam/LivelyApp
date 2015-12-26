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


@protocol DialogViewControllerDelegate <NSObject>

- (void)secondViewScreenControllerDidPressCancelButton:(UIViewController *)viewController sender:(id)sender;

// Any other button possibilities

@end

@class QBRTCSession;

@interface DialogViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) id<DialogViewControllerDelegate> delegate;
@property UIImageView *currentUserImage;
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property UIImage *imageForRightBar;
@property (weak, nonatomic) IBOutlet UIButton *takePicButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSMutableArray *userPhotos;

@property NSString *userFullName;
@property QBChatDialog *userDialogs;
@property NSInteger passedUserId;
@property NSString *passedDialogId;
@property QBChatMessage *messageToBeUsed;

@property (strong, nonatomic) QBRTCSession *session;

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer;
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
-(void)doubleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer2;


@end


