//
//  ContactListTableViewCell.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/16/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@interface ContactListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseContactButton;
@property (nonatomic, strong) QBUUser *user;
@property (nonatomic, strong) NSString *userDescription;
@end
