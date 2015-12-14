//
//  MainTableViewCell.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface MainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeOfMessage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *textMessage;
@property (weak, nonatomic) IBOutlet UILabel *unreadMessagesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *isLiveIndicator;


@end
