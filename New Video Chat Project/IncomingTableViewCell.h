//
//  IncomingTableViewCell.h
//  
//
//  Created by Edil Ashimov on 11/16/15.
//
//

#import <UIKit/UIKit.h>

@interface IncomingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *incomingLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageincom;
@property (weak, nonatomic) IBOutlet UILabel *incomingMessageTime;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
