//
//  IncomingViewController.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 11/20/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "IncomingViewController.h"
#import "DialogViewController.h"

@implementation IncomingViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
   self.view.frame = CGRectMake (60,157, 280.f, 370.f);
}

-(void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"-------------%@-----------------", self.session);
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (IBAction)acceptCall:(id)sender {

    NSDictionary *userInfo = @{ @"key" : @"value" };
    [self.session acceptCall:userInfo];
    [self performSegueWithIdentifier:@"startVideoSeg" sender:self];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startVideoSeg"]) {
        DialogViewController *dvc = segue.destinationViewController;
        dvc.session = self.session;
    }
}

@end
