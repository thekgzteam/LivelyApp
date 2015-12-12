//
//  ContactsAndGroups.h
//  New Video Chat Project
//
//  Created by Edil Ashimov on 10/24/15.
//  Copyright © 2015 Edil Ashimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsAndGroups : UIViewController <UIViewControllerTransitioningDelegate, ABPeoplePickerNavigationControllerDelegate>

@property NSMutableArray *username;
@property NSMutableArray *images;
@property NSArray *filteredResults;

@end
