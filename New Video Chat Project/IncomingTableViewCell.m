//
//  IncomingTableViewCell.m
//  
//
//  Created by Edil Ashimov on 11/16/15.
//
//

#import "IncomingTableViewCell.h"

@implementation IncomingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImageincom.layer.cornerRadius = 14;
    self.profileImageincom.layer.masksToBounds = YES;
    self.profileImageincom.layer.borderColor=[[UIColor whiteColor] CGColor];

    self.arrowLabel.layer.cornerRadius = 25;
    self.arrowLabel.layer.masksToBounds = YES;
    self.incomingLabel.layer.cornerRadius = 5;


}

@end
