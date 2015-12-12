//
//  ContactListViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/12/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBChatDialog;

@interface ContactListViewController : UIViewController 
@property NSString *groupName;
@property IBOutlet UIImageView *uploadImage;
@property QBChatDialog *chatDialog;
@property NSMutableArray *userIdInt;
@end
