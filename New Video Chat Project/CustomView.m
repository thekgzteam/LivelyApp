//
//  CustomView.m
//
//  Code generated using QuartzCode 1.21 on 11/27/15.
//  www.quartzcodeapp.com
//

#import "CustomView.h"
#import "QCMethod.h"


@interface CustomView ()

@property (nonatomic, strong) CALayer *image;
@property (nonatomic, strong) CALayer *image2;
@property (nonatomic, strong) CALayer *image3;

@end

@implementation CustomView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setupLayers];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self setupLayers];
	}
	return self;
}


- (void)setupLayers{
	CALayer * image = [CALayer layer];
	image.frame    = CGRectMake(0, 1, 10, 10);
	image.contents = (id)[UIImage imageNamed:@"circle"].CGImage;
	[self.layer addSublayer:image];
	_image = image;
	
	CALayer * image2 = [CALayer layer];
	image2.frame    = CGRectMake(13.3, 1, 10, 10);
	image2.contents = (id)[UIImage imageNamed:@"circle"].CGImage;
	[self.layer addSublayer:image2];
	_image2 = image2;
	
	CALayer * image3 = [CALayer layer];
	image3.frame    = CGRectMake(26.6, 1, 10, 10);
	image3.contents = (id)[UIImage imageNamed:@"circle"].CGImage;
	[self.layer addSublayer:image3];
	_image3 = image3;
}


- (IBAction)startAllAnimations:(id)sender{
	[self.image addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
	[self.image2 addAnimation:[self image2Animation] forKey:@"image2Animation"];
	[self.image3 addAnimation:[self image3Animation] forKey:@"image3Animation"];
}

- (CABasicAnimation*)imageAnimation{
	CABasicAnimation * positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnim.toValue            = [NSValue valueWithCGPoint:CGPointMake(6, 16)];
	positionAnim.duration           = 0.178;
	positionAnim.autoreverses       = YES;
	positionAnim.fillMode = kCAFillModeForwards;
	positionAnim.removedOnCompletion = NO;
    positionAnim.repeatCount = 60;
	
	return positionAnim;
}

- (CAAnimationGroup*)image2Animation{
	CABasicAnimation * positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnim.toValue            = [NSValue valueWithCGPoint:CGPointMake(18, 16)];
	positionAnim.duration           = 0.198;
	positionAnim.beginTime          = 0.178;
	positionAnim.autoreverses       = YES;

	CAAnimationGroup *imageAnimGroup   = [CAAnimationGroup animation];
	imageAnimGroup.animations          = @[positionAnim];
	[imageAnimGroup.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
	imageAnimGroup.fillMode            = kCAFillModeForwards;
	imageAnimGroup.removedOnCompletion = NO;
	imageAnimGroup.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup.animations];
    imageAnimGroup.repeatCount = 60;
	
	
	return imageAnimGroup;
}

- (CAAnimationGroup*)image3Animation{
	CABasicAnimation * positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
	positionAnim.toValue            = [NSValue valueWithCGPoint:CGPointMake(30, 16)];
	positionAnim.duration           = 0.197;
	positionAnim.beginTime          = 0.38;
	positionAnim.autoreverses       = YES;



	CAAnimationGroup *imageAnimGroup   = [CAAnimationGroup animation];
	imageAnimGroup.animations          = @[positionAnim];
	[imageAnimGroup.animations setValue:kCAFillModeForwards forKeyPath:@"fillMode"];
	imageAnimGroup.fillMode            = kCAFillModeForwards;
	imageAnimGroup.removedOnCompletion = NO;
	imageAnimGroup.duration = [QCMethod maxDurationFromAnimations:imageAnimGroup.animations];
    imageAnimGroup.repeatCount = 60;
	
	
	return imageAnimGroup;
}

@end