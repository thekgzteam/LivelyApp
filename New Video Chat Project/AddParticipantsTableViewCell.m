//
//  AddParticipantsTableViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "AddParticipantsTableViewCell.h"

@implementation AddParticipantsTableViewCell
- (void)awakeFromNib {
    // Initialization code
    self.participantImage.layer.backgroundColor=[[UIColor clearColor] CGColor];
    self.participantImage.layer.cornerRadius = 12;
    self.participantImage.layer.masksToBounds = YES;
}
@end
