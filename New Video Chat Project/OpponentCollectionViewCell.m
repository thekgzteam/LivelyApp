//
//  OpponentCollectionViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OpponentCollectionViewCell.h"

@interface OpponentCollectionViewCell()


@property (weak, nonatomic) IBOutlet UIView *containerView;

//@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation OpponentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)gesture {
}

- (void)setVideoView:(UIView *)videoView {
    
    if (_videoView != videoView) {

        [_videoView removeFromSuperview];
        _videoView = videoView;
        _videoView.frame = self.bounds;
        [self.containerView insertSubview:_videoView atIndex:0];

    }
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (CGRectEqualToRect(_videoView.bounds, self.bounds)) {
        
        return;
    }
    _videoView.frame = self.bounds;
}



@end
