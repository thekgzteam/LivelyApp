//
//  TextTableViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/16/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "TextTableViewCell.h"
#import "POP.h"

@interface TextTableViewCell ()

@property (nonatomic) UIImageView *messageImageView;
@end
@implementation TextTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.messageImageView = [[UIImageView alloc]init];
        self.messageImageView.tag = 1;
        self.messageImageView.frame = CGRectMake(100, 30, 150, 90);
        [self addSubview:self.messageImageView];
    }

    return self;
}

- (void)updateWithImage:(UIImage *)image
{
    self.messageImageView.image = image;
}

-(void)removeImage
{
    if (self.messageImageView.image) {
        self.messageImageView.image = nil;
    }
}

-(void)assignText:(NSString *)text
{
    self.messageLabel.text = text;
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [self.messageLabel pop_addAnimation:scaleAnimation forKey:@"scalingUp"];



    } else {
        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        sprintAnimation.springBounciness = 20.f;
        [self.messageLabel pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
    }
}
@end
