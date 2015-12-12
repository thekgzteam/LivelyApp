//
//  AllMediaCollectionViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "AllMediaCollectionViewCell.h"

@implementation AllMediaCollectionViewCell

- (void)awakeFromNib {

    self.allImagesImageView.layer.cornerRadius = 4;
    self.allImagesImageView.layer.masksToBounds = YES;
}
@end
