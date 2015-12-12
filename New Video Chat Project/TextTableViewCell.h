//
//  TextTableViewCell.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/16/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *deviceLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIImageView *messageStatus;

-(void)updateWithImage:(UIImage *)image;
-(void)removeImage;
-(void)assignText:(NSString *)text;

@end
