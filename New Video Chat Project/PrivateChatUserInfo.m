//
//  PrivateChatUserInfo.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "PrivateChatUserInfo.h"
#import "AllMediaCollectionViewCell.h"
#import "UserInfoCell.h"

@implementation PrivateChatUserInfo

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGSize size = CGSizeMake(380,580);
    self.preferredContentSize = size;
    self.view.center = CGPointMake(100, 100);

    [self.userProfileImage.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.userProfileImage.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.userProfileImage.layer addAnimation:[self rotationAnimation] forKey:@"rotationAnimation"];
    [self.name.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.name.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.mediaCount.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.mediaCount.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.collectionView.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.collectionView.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.tableView.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.tableView.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.allMediaLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.allMediaLabel.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.userInfoandActionsLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.userInfoandActionsLabel.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];


    [self.dismissButton.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.userProfileImage.image = self.imageForUserProfileImage;

    self.userProfileImage.layer.cornerRadius = 50;
    self.userProfileImage.layer.masksToBounds = YES;

    self.dismissButton.layer.cornerRadius = 15.0f;

    self.arrayOfImages = [[NSArray alloc]initWithObjects:
                          [UIImage imageNamed:@"Edil Ashimov"],
                          [UIImage imageNamed:@"image"],
                          [UIImage imageNamed:@"help"],
                          [UIImage imageNamed:@"Nick Cannon"],
                          [UIImage imageNamed:@"facebook"],
                          [UIImage imageNamed:@"camera"],
                          [UIImage imageNamed:@"legal"],
                          [UIImage imageNamed:@"circle"],
                          [UIImage imageNamed:@"checked"],
                          nil];

    

    NSString *mediaCount = [@(self.arrayOfImages.count) stringValue];
    self.mediaCount.text = [[@"(" stringByAppendingString:mediaCount] stringByAppendingString:@" Files)"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfImages.count;

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AllMediaCollectionViewCell *cell = (AllMediaCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"userInfoCell" forIndexPath:indexPath];
        cell.allImagesImageView.image = [self.arrayOfImages objectAtIndex:indexPath.row];
        cell.allImagesImageView.layer.cornerRadius = 4.0f;

    return cell;
}


#pragma mark - TABLE VIEW METHODS -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    
    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"first";
            break;

        case 1:
            CellIdentifier = @"second";
            break;

        case 2:
            CellIdentifier = @"third";
            break;
        case 3:
            CellIdentifier = @"fourth";
            break;

        case 4:
            CellIdentifier = @"fifth";
            break;

        case 5:
            CellIdentifier = @"sixth";
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];

    return cell;
}

- (CABasicAnimation*)imageAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];;
    transformAnim.duration           = 0.1;
    transformAnim.autoreverses       = YES;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.fromValue          = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)];;
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DIdentity];;
    transformAnim.duration           = 0.398;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}

- (CABasicAnimation*)ovalAnimationOpacity{
    CABasicAnimation * opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue          = @0;
    opacityAnim.toValue            = @1;
    opacityAnim.duration           = 0.652;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.removedOnCompletion = NO;

    return opacityAnim;
}

- (CABasicAnimation*)rotationAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    transformAnim.toValue            = @(-360 * M_PI/180);
    transformAnim.duration           = 0.435;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;

    return transformAnim;
}
- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];

}
@end
