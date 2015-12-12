//
//  UserIsTypingCell.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/26/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"

@interface UserIsTypingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userIsTyping;
@property (weak, nonatomic) IBOutlet CustomView *customView;

@end
