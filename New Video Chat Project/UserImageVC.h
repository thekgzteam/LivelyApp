//
//  UserImageVC.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/27/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserImageVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property UIImage *imageForUserImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userStatus;

@end
