//
//  UserInfoPopOverVC.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatInfoPopOver : UIViewController <UITableViewDataSource, UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property UIImage *imageForUserProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property NSArray *arrayOfImages;
@property (weak, nonatomic) IBOutlet UILabel *mediaCount;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *participantsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addParticipantsButton;

@end
