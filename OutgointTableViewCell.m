//
//  OutgointTableViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/16/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "OutgointTableViewCell.h"
#import "QCMethod.h"
#import "POP.h"


@implementation OutgointTableViewCell

- (void)awakeFromNib {

    self.layer.cornerRadius = 6;
    self.profileImage.layer.cornerRadius = 14;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [[UIColor clearColor] CGColor];
    self.profileImage.layer.borderWidth = 2.0f;
    self.statusIcon.image = [UIImage imageNamed:@"readStatus"];
    self.profileImage.layer.backgroundColor = [UIColor grayColor].CGColor;

    self.arrowLabel.layer.cornerRadius = 25;
    self.arrowLabel.layer.masksToBounds = YES;
    self.outgoingLabel.layer.cornerRadius = 5;





}

@end
