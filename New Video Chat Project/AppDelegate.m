
//
//  AppDelegate.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/13/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import <SinchVerification/SinchVerification.h>


@interface AppDelegate ()


@end

@implementation AppDelegate

const NSTimeInterval kQBAnswerTimeInterval = 1000.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 30.f;
const NSTimeInterval kQBDialingTimeInterval = 1000.f;

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.restrictRotation)
        return UIInterfaceOrientationMaskPortrait;
    else
        return UIInterfaceOrientationMaskAll;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {



    [QBSettings setApplicationID:30638];
    [QBSettings setAuthKey:@"Ab7jmnDcEB3KSVH"];
    [QBSettings setAuthSecret:@"d2jBQAgrBhtFvH6"];
    [QBSettings setAccountKey:@"7yvNe17TnjNUqDoPwfqp"];
    [QBSettings setAutoReconnectEnabled:YES];
    [QBSettings setLogLevel:QBLogLevelDebug];


    // Is user is signed in proceed to MainVC
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    __kindof UIViewController *initialVC;
    

    if ([QBSession currentSession].currentUser) {
        initialVC = [main instantiateViewControllerWithIdentifier:@"SWRevealVC"];
    }
    else {
        initialVC = [main instantiateViewControllerWithIdentifier:@"LogInNav"];
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = initialVC;
    [self.window makeKeyAndVisible];
   
     [QBSettings setLogLevel:QBLogLevelNothing];

    //QuickbloxWebRTC preferences

    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCClient initializeRTC];
    [QBSettings setLogLevel:QBLogLevelNothing];
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

if ([[vComp objectAtIndex:0] intValue] >= 8) {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationActivationModeBackground categories:nil]];
}
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
                                                        object:nil];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;

    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {

    } errorBlock:^(QBResponse *response) {
        
    }];
}
- (void)registerForRemoteNotifications{

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {

        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}
- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QBChat instance] connectWithUser:[QBSession currentSession].currentUser completion:^(NSError * _Nullable error) {
    }];
}
@end
