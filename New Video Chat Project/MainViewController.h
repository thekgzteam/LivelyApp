//
//  MainViewController.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "DialogViewController.h"

@interface MainViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property NSArray *username;
@property NSMutableArray *images;
@property NSArray *textMessages;
@property NSMutableArray *userPhotos;
@property NSMutableArray *userPrivatePhotos;

@property NSMutableArray *liveIndexPaths;


@property (weak, nonatomic) IBOutlet UIButton *writeNewMessage;
@property (strong, nonatomic) NSString *myUserId;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property NSString *usersRetrievedFullName;
@property QBChatDialog *userDialogToBePassed;
@property NSString *navBarTitle;
@property UIImage *imageToDialogVC;


@end

