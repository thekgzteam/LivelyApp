//
//  CreateTableViewCell.h
//  Pods
//
//  Created by Edil Ashimov on 12/24/15.
//
//




#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

@interface CreateTableViewCell : UITableViewCell <QBChatDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *contactsImage;
@property (weak, nonatomic) IBOutlet UILabel *contactsName;

@end
