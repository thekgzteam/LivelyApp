//
//  IncomingTableViewCell.m
//  
//
//  Created by Edil Ashimov on 11/16/15.
//
//

#import "IncomingTableViewCell.h"

@implementation IncomingTableViewCell


#pragma mark - Bezier Path

- (UIBezierPath*)pathPath{
    UIBezierPath *pathPath = [UIBezierPath bezierPath];
    [pathPath moveToPoint:CGPointMake(15,  5)];
    [pathPath addLineToPoint:CGPointMake(15,  25)];
    [pathPath addLineToPoint:CGPointMake(0,  20.424)];
    [pathPath addLineToPoint:CGPointMake(15,  15)];

    return pathPath;
}

- (void)awakeFromNib {
    // Initialization code
    self.profileImageincom.layer.cornerRadius = 14;
    self.profileImageincom.layer.masksToBounds = YES;
    self.profileImageincom.layer.borderColor = [[UIColor whiteColor] CGColor];

    self.arrowLabel.layer.cornerRadius = 25;
    self.arrowLabel.layer.masksToBounds = YES;
    self.incomingLabel.layer.cornerRadius = 5;


    CAShapeLayer * path = [CAShapeLayer layer];
    path.frame     = CGRectMake(2, 0, 15, 10);
    path.fillColor = [[UIColor colorWithRed:170 green:170 blue:170 alpha:0.5]CGColor];
    path.lineWidth = 0;
    path.path      = [self pathPath].CGPath;
    [self.arrowView.layer addSublayer:path];
}


@end
