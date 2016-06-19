//
//  EmailAddressTableViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 2/18/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "EmailAddressViewController.h"

@interface EmailAddressTableViewController : UITableViewController /*<UITableViewDelegate, UITableViewDataSource,*/
{
	NSMutableArray *emailAddressItems;
	EmailAddressViewController *emailAddressViewController;
}

@property (assign) NSMutableArray *emailAddressItems;
@property (assign) EmailAddressViewController *emailAddressViewController;

- (id)initWithEmailAddressViewController:(EmailAddressViewController *)emailAVC;

@end