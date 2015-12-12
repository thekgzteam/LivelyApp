//
//  UserInfoPopOverVC.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/28/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "GroupChatInfoPopOver.h"
#import "AllMediaCollectionViewCell.h"
#import "Storage.h"
#import "AddParticipantsTableViewCell.h"
#import <Quickblox/Quickblox.h>


@implementation GroupChatInfoPopOver 

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // QUESTION 15

    CGSize size = CGSizeMake(380,580);
    self.preferredContentSize = size;

    [self.dismissButton.layer addAnimation:[self imageAnimation] forKey:@"imageAnimation"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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
    [self.participantsLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.participantsLabel.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
    [self.addParticipantsButton.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
    [self.addParticipantsButton.layer addAnimation:[self ovalAnimationOpacity] forKey:@"ovalAnimationOpacity"];
}

- (IBAction)onDismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];

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

#pragma mark -    COLLECTION VIEW METHODS -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfImages.count;

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AllMediaCollectionViewCell *cell = (AllMediaCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"userInfoCell" forIndexPath:indexPath];
    cell.allImagesImageView.image = [self.arrayOfImages objectAtIndex:indexPath.row];
//    cell.allImagesImageView.layer.cornerRadius = 4.0f;

    return cell;
}

#pragma mark - TABLE VIEW METHODS -

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [[Storage instance].users count];;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 1;
}
- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddParticipantsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell"];
    QBUUser *user = [[Storage instance].users objectAtIndex:indexPath.row];
    cell.participantName.text = user.fullName != nil ? user.fullName : user.login;
    cell.participantImage.image =[UIImage imageNamed:@"Profile Picture"];
    return cell;
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
@end
