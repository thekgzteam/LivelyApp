//
//  ContactsAndGroupsTableViewCell.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/26/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>


@interface ContactsAndGroupsTableViewCell : UITableViewCell <QBChatDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *contactsImage;
@property (weak, nonatomic) IBOutlet UILabel *contactsName;
@property (weak, nonatomic) IBOutlet UILabel *userOnlineIndicatorLabel;

@end
