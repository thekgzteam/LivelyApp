//
//  ContactsAndGroups.m
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/24/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import "ContactsAndGroups.h"
#import "ContactsAndGroupsTableViewCell.h"

#import "SWRevealViewController.h"
#import <Quickblox/Quickblox.h>
#import "SVProgressHUD.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"

#import "Storage.h"
#import "UsersPaginator.h"
#import "NMPaginator.h"
#import "UserProfileViewController.h"
#import "GroupInfoCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKGraphRequest.h>


@interface ContactsAndGroups () <UITableViewDelegate, UITableViewDataSource, NMPaginatorDelegate,FBSDKGraphRequestConnectionDelegate, ABNewPersonViewControllerDelegate>



@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *addNewContact;
@property (nonatomic, strong) UsersPaginator *paginator;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property NSMutableArray *arrayForBool;

@property NSMutableArray *groups;
@property NSMutableDictionary *sectionContentDict;

@property NSMutableArray *groups2;
@property NSMutableDictionary *sectionContentDict2;

@property NSMutableArray *phoneNumberArray;
@property NSMutableArray *groupOfContacts;

@property (nonatomic, strong) CNContactViewController *newconctact;
@property (nonatomic, strong) ABNewPersonViewController *addressBookController;
@property (strong, nonatomic) UINavigationController *nav;




@end

@implementation ContactsAndGroups

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.segmentedControl setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:1.0 alpha:1.0]]  forState:UIControlStateSelected  barMetrics:UIBarMetricsDefault];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, self.segmentedControl.frame.size.height), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.segmentedControl setDividerImage:blank
                forLeftSegmentState:UIControlStateNormal
                  rightSegmentState:UIControlStateNormal
                         barMetrics:UIBarMetricsDefault];

    self.footerLabel.backgroundColor = [UIColor colorWithRed:137/255.0f green:196/255.0f blue:244/255.0f alpha:1.0];
    self.navBar.barTintColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    self.navBar.tintColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    self.navBar.backgroundColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.searchBar.backgroundImage = [[UIImage alloc] init];

   self.searchBar.backgroundColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];

    UIBarButtonItem *l_backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(perform:)];

    self.navigationItem.leftBarButtonItem = l_backButton;
    l_backButton.title = @"Go Back";


    // REMOVING CURRENT USER FROM LIST OF ALL FETCHED USERS
    [[Storage instance].users removeObject:[QBSession currentSession].currentUser];

    // LOCAL CONTACT LIST
    self.groupOfContacts = [@[] mutableCopy];
    [self getAllContact];

    self.phoneNumberArray = [@[] mutableCopy];
    for (CNContact *contact in self.groupOfContacts)
    {
        NSArray *thisOne = [[contact.phoneNumbers valueForKey:@"value"] valueForKey:@"digits"];
        [self.phoneNumberArray addObjectsFromArray:thisOne];
        NSLog(@"------%@-----yes---",contact.givenName);
    }


    // INITIALIZING ARRAYS WITH DICTIONARIES
       if (!self.groups) {
        self.groups = [NSMutableArray arrayWithObjects:@"Friends", @"Family", @"Work", nil];
    }

    if (!self.groups2) {
        self.groups2 = [NSMutableArray arrayWithObjects:@"Lively Users", @"Local Contacts", @"Facebook Contacts", nil];
    }

    if (!self.arrayForBool) {
        self.arrayForBool    = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO] , nil];
    }

    if (!self.sectionContentDict) {
        self.sectionContentDict  = [[NSMutableDictionary alloc] init];
        NSArray *array1     = [NSArray arrayWithObjects:@"Friend 1", @"Friend 2", @"Friend 3", @"Friend 4", nil];
        [self.sectionContentDict setValue:array1 forKey:[self.groups objectAtIndex:0]];
        NSArray *array2     = [NSArray arrayWithObjects:@"Family 1", @"Family 2", @"Family 3", nil];
        [self.sectionContentDict setValue:array2 forKey:[self.groups objectAtIndex:1]];
        NSArray *array3     = [NSArray arrayWithObjects:@"Work 1", @"Work 2", @"Work 3", @"Work 4", nil];
        [self.sectionContentDict setValue:array3 forKey:[self.groups objectAtIndex:2]];

    }
    if (!self.sectionContentDict2) {
        self.sectionContentDict2  = [[NSMutableDictionary alloc] init];
        NSArray *array11     = [NSArray arrayWithArray:[Storage instance].users];
        [self.sectionContentDict2 setValue:array11 forKey:[self.groups2 objectAtIndex:0]];

        NSArray *array22     = [NSArray arrayWithArray:self.groupOfContacts];
        [self.sectionContentDict2 setValue:array22 forKey:[self.groups2 objectAtIndex:1]];
        NSArray *array33     = [NSArray arrayWithArray:[Storage instance].users];
        [self.sectionContentDict2 setValue:array33 forKey:[self.groups2 objectAtIndex:2]];
    }


    // CUSTOM UI DESIGN
    self.addNewContact.layer.cornerRadius= 30;
    self.addNewContact.layer.masksToBounds = YES;
    self.addNewContact.layer.borderColor=[[UIColor redColor] CGColor];

    self.paginator = [[UsersPaginator alloc] initWithPageSize:10 delegate:self];
    [self updateTableViewFooter];
    [self.tableView reloadData];

}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {

    [newPersonView dismissViewControllerAnimated:YES completion:nil];


}

-(void) perform:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)addNewContactButton:(id)sender {


    // QUESTION 16

//    self.addressBookController = [[ABNewPersonViewController alloc] init];

    ABNewPersonViewController *addressBookController =[[ABNewPersonViewController alloc] init];

    addressBookController.newPersonViewDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addressBookController];

    [self presentViewController:nav animated:YES completion:nil];
}


// FETCHING ALL LOCAL CONTACTS
-(void)getAllContact {

    if ([CNContactStore class])
    {
        CNContactStore *addressBook = [[CNContactStore alloc]init];
        NSArray *keysToFetch = @[CNContactEmailAddressesKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactPhoneNumbersKey,CNContactPostalAddressesKey,CNContactImageDataKey];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc]initWithKeysToFetch:keysToFetch];
        [addressBook enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            [self.groupOfContacts addObject:contact];
        }];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.paginator fetchFirstPage];
}

- (void)fetchNextPage {
    [self.paginator fetchNextPage];
}


    // SEGMENT CONTROL MEHTOD
- (IBAction)segmentedControlChanged:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.tableView reloadData];

            break;
        case 1:
            [self.tableView reloadData];
            break;
    }
}

#pragma mark - table view methods -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            return  self.groups2.count;
            break;

            case 1:
            return self.groups.count;
            break;
    }
    return 3;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            if ([[self.arrayForBool objectAtIndex:section] boolValue]) {
                return [[self.sectionContentDict2 valueForKey:[self.groups2 objectAtIndex:section]] count];
            break;
        case 1:
            if ([[self.arrayForBool objectAtIndex:section] boolValue]) {
                return [[self.sectionContentDict valueForKey:[self.groups objectAtIndex:section]] count];
                break;
            }
        }
    }
    return  0;
}

// TABLE VIEW HEADER VIEW METHOD
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    headerView.tag                  = section;
    headerView.backgroundColor      = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = headerView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
//    [headerView.layer insertSublayer:gradient atIndex:0];


    UILabel *headerString           = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20-50, 50)];
    headerString.font  = [UIFont fontWithName:@"Avenir" size:18.5];
    BOOL manyCells                  = [[self.arrayForBool objectAtIndex:section] boolValue];

    switch (self.segmentedControl.selectedSegmentIndex) {

        case 0:
            if(self.segmentedControl.selectedSegmentIndex == 0) {

                if (!manyCells) {
                    headerString.text = [self.groups2 objectAtIndex:section];
                    headerString.textColor = [UIColor whiteColor];
                    [headerString setShadowOffset:CGSizeMake(1, 0.7)];

                } else {
                    headerString.text = [self.groups2 objectAtIndex:section];
                    headerString.textColor          = [UIColor colorWithRed:233/255.0f green:212/255.0f blue:96/255.0f alpha:1.0];
                    [headerString setShadowOffset:CGSizeMake(1, 0.7)];

            }
                headerString.textAlignment      = NSTextAlignmentLeft;
                [headerView addSubview:headerString];
                break;
            }
            case 1:
                if(self.segmentedControl.selectedSegmentIndex == 1) {
                    
                    if (!manyCells) {
                        headerString.text = [self.groups objectAtIndex:section];
                        headerString.textColor          = [UIColor blackColor];

                    }else{
                        headerString.text = [self.groups objectAtIndex:section];
                        headerString.textColor          = [UIColor blueColor];
                }
                    headerString.textAlignment      = NSTextAlignmentLeft;
                    [headerView addSubview:headerString];
                    break;
                }
        }

    // GESTURE RECOGNIZER FOR HEADER VIEW TAPPING
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];

    //UP OR DOWN ARROW DEPENDING ON THE BOOL
    UIImageView *upDownArrow        = [[UIImageView alloc] initWithImage:manyCells ? [UIImage imageNamed:@"upArrowBlack"] : [UIImage imageNamed:@"downArrowBlack"]];
    upDownArrow.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin;
    upDownArrow.frame               = CGRectMake(self.view.frame.size.width-40, 10, 30, 30);
    [headerView addSubview:upDownArrow];

    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer  = [[UIView alloc] initWithFrame:CGRectZero];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([[self.arrayForBool objectAtIndex:indexPath.section] boolValue]) {
        return 45;
    }
    return 2;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // QUESTION 5

    ContactsAndGroupsTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"contactscellid"];

    cell.backgroundView.backgroundColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0];
    cell.backgroundColor = [UIColor colorWithRed:103/255.0f green:128/255.0f blue:159/255.0f alpha:1.0];
    cell.contactsName.textColor = [UIColor whiteColor];

    NSArray *content2 = [self.sectionContentDict2 valueForKey:[self.groups2 objectAtIndex:indexPath.section]];

    if (self.segmentedControl.selectedSegmentIndex == 0) {

        switch (indexPath.section) {

            case 0:{
                QBUUser *user = [content2 objectAtIndex:indexPath.row];
                cell.contactsName.text = user.fullName;

//                NSArray *userids = [NSArray arrayWithArray:[Storage instance].users];
//                [QBRequest usersWithIDs:userids page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
//                    for (QBUUser *user in users) {
//                        NSUInteger userProfilePictureID = user.blobID;
//
//                        [QBRequest downloadFileWithID:userProfilePictureID successBlock:^(QBResponse * _Nonnull response, NSData * _Nonnull fileData) {
//                            if (fileData == nil) {
                                cell.contactsImage.image = [UIImage imageNamed:@"Profile Picture-1"];
//                            }
//                            else
//                            cell.contactsImage.image = [UIImage imageWithData:fileData];
//                            
//                        } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
//                            nil;
//                        } errorBlock:^(QBResponse * _Nonnull response) {
//                        }];
//                    }

//                } errorBlock:^(QBResponse *response) {
//                    // Handle error here
//                }];

                NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
                NSInteger userLastRequestAtTimeInterval   = [[user lastRequestAt] timeIntervalSince1970];



//            TO DO  1 , USER ONlINE
                if((currentTimeInterval - userLastRequestAtTimeInterval) > 30){
                    cell.userOnlineIndicatorLabel.enabled = YES;
                    cell.userOnlineIndicatorLabel.hidden = NO;
        [cell.userOnlineIndicatorLabel.layer addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
                }
//                else
//                    cell.userOnlineIndicatorLabel.enabled = NO;
//                cell.userOnlineIndicatorLabel.hidden = YES;
                }
                break;
            case 1: {
                CNContact *contact = [content2 objectAtIndex:indexPath.row];
                cell.contactsName.text = contact.givenName;
                cell.userOnlineIndicatorLabel.enabled = NO;
                cell.userOnlineIndicatorLabel.hidden = YES;

                if (contact.imageData == nil) {
                    cell.contactsImage.image = [UIImage imageNamed:@"Profile Picture-1"];
                }
                else
                cell.contactsImage.image = [UIImage imageWithData:contact.imageData];
                cell.userOnlineIndicatorLabel.enabled = NO;
                cell.userOnlineIndicatorLabel.hidden = YES;
            }
                break;
            case 2:
//            {
//                QBUUser *user = [content2 objectAtIndex:indexPath.row];
//                cell.contactsName.text = user.fullName;
//            }
                break;
            default:
                break;
        }
    }
    return cell;


//        NSArray *content3 = [self.sectionContentDict2 valueForKey:[self.groups2 objectAtIndex:indexPath.section]];
//
//        QBUUser *user = [content2 objectAtIndex:indexPath.row];
//
//        cell.contactsName.text = user.fullName;
//        cell.contactsName.text = contact.givenName;
//        cell.contactsImage.image =[UIImage imageNamed:@"Profile Picture"];
//
//        return cell;
//      } else {
//
//        GroupCroupsCell *groupCell = [tableView dequeueReusableCellWithIdentifier:@"groupsCellId"];
//
//        NSArray *content = [self.sectionContentDict valueForKey:[self.groups objectAtIndex:indexPath.section]];
//        groupCell.username.text = [content objectAtIndex:indexPath.row];
//
//    return groupCell;
//
//    }
}

#pragma mark - user interaction -

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showUserPage];
    [self.view endEditing:YES];
}

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results {
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
}

    // ACTION TO SHOW SELECTED USER PROFILE
- (IBAction)showUserPage {

    UserProfileViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfilePage"];
    modalVC.transitioningDelegate = self;
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    ContactsAndGroupsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    modalVC.userFullName = cell.contactsName.text;

    [self presentViewController:modalVC animated:YES completion:nil];
}

    // SEGUES
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userProfileSeg"]){
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        ContactsAndGroupsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        UserProfileViewController *dvc = segue.destinationViewController;
        dvc.userFullName = cell.contactsName.text;
    }
}

    // GESTURE RECOGNIZER FOR HEADER VIEW TAPPED
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[self.arrayForBool objectAtIndex:indexPath.section] boolValue];
        collapsed       = !collapsed;
        [self.arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];

        //reload specific section animated
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIViewControllerTransitionDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissingAnimationController alloc] init];
}

- (void)updateTableViewFooter {

    self.footerLabel.text = [NSString stringWithFormat:@"%lu results", (unsigned long)[[Storage instance].users count]];
    [self.footerLabel setNeedsDisplay];
}

- (CABasicAnimation*)ovalAnimation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnim.toValue            = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)];;
    transformAnim.duration           = 0.3;
    transformAnim.autoreverses       = YES;
    transformAnim.fillMode = kCAFillModeBoth;
    transformAnim.removedOnCompletion = NO;
    transformAnim.repeatCount = 100;

    return transformAnim;
}


@end
