//
//  CreateMessageTableViewCell.m
//  Pods
//
//  Created by Edil Ashimov on 12/24/15.
//
//

//
//  CreateTableViewCell.m
//  Pods
//
//  Created by Edil Ashimov on 12/24/15.
//
//

#import "CreateMessageTableViewCell.h"
#import "POP.h"
#import "Storage.h"
@implementation CreateMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contactsImage.layer.backgroundColor=[[UIColor clearColor] CGColor];
    self.contactsImage.layer.cornerRadius = 15;
    self.contactsImage.layer.masksToBounds = YES;
    self.contactsImage.layer.borderColor=[[UIColor redColor] CGColor];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        [self.textLabel pop_addAnimation:scaleAnimation forKey:@"scalingUp"];



    } else {
        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        sprintAnimation.springBounciness = 20.f;
        [self.textLabel pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
    }
}

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)];;
    transformAnim.duration           = 0.3;
    transformAnim.autoreverses       = YES;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;
    transformAnim.repeatCount = 40;

    return transformAnim;
}

@end