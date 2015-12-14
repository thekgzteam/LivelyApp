//
//  MainTableViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/15/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell



- (void)awakeFromNib {
    // Initialization code
    self.profileImage.layer.backgroundColor=[[UIColor clearColor] CGColor];
    self.profileImage.layer.cornerRadius = 20;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor=[[UIColor redColor] CGColor];
    self.unreadMessagesCountLabel.layer.cornerRadius = 10;
    self.unreadMessagesCountLabel.layer.masksToBounds = YES;

    self.isLiveIndicator.hidden = YES;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    UIColor *color = self.unreadMessagesCountLabel.backgroundColor;
    [super setSelected:selected animated:animated];

    if (selected) {
        self.unreadMessagesCountLabel.backgroundColor = color;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    UIColor *color = self.unreadMessagesCountLabel.backgroundColor;
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        self.unreadMessagesCountLabel.backgroundColor = color;
    }
}


@end
