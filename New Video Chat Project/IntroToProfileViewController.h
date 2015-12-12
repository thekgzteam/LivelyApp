//
//  IntroToProfileViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroToProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
@property NSString *myUserId;
- (IBAction)ChooseExisting;
@property NSNumber *phoneDigits;
- (IBAction)showNormalActionSheet:(id)sender;
@end
