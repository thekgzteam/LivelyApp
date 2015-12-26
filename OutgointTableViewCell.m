//
//  OutgointTableViewCell.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/16/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "OutgointTableViewCell.h"
#import "QCMethod.h"
#import "POP.h"


@implementation OutgointTableViewCell


#pragma mark - Bezier Path

- (UIBezierPath*)pathPath{
    UIBezierPath *pathPath = [UIBezierPath bezierPath];
    [pathPath moveToPoint:CGPointMake(0, 0)];
    [pathPath addLineToPoint:CGPointMake(0.005, 10.465)];
    [pathPath addLineToPoint:CGPointMake(15.18, 5.588)];
    [pathPath addLineToPoint:CGPointMake(0, 0)];

    return pathPath;



}

- (void)awakeFromNib {

    self.layer.cornerRadius = 6;
    self.profileImage.layer.cornerRadius = 14;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [[UIColor clearColor] CGColor];
    self.profileImage.layer.borderWidth = 2.0f;
    self.statusIcon.image = [UIImage imageNamed:@"readStatus"];
    self.profileImage.layer.backgroundColor = [UIColor grayColor].CGColor;

    self.arrowLabel.layer.cornerRadius = 25;
    self.arrowLabel.layer.masksToBounds = YES;
    self.outgoingLabel.layer.cornerRadius = 5;



    CAShapeLayer * path = [CAShapeLayer layer];
    path.frame     = CGRectMake(1, 12, 10, 8);
    path.fillColor = [[UIColor colorWithRed:39/255.0f green:126/255.0f blue:255/255.0f alpha:0.3]CGColor];
    path.lineWidth = 0;
    path.path      = [self pathPath].CGPath;
    [self.arrowView.layer addSublayer:path];



}


@end
