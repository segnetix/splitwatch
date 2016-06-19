//
//  EmailAddressViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 1/31/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class EmailAddressTableViewController;
@class StopwatchAppDelegate;

@interface EmailAddressViewController : UIViewController /*<UITableViewDelegate, UITableViewDataSource,*/
														  <UITextFieldDelegate,
														  ABPeoplePickerNavigationControllerDelegate,
														  UINavigationControllerDelegate>
{
	UITextField *emailTextField;
	EmailAddressTableViewController *emailAddressTableViewController;
	NSMutableArray *emailAddressItems;
	StopwatchAppDelegate *appDelegate;
    
    UILabel *label;
    UIButton *button;
}

@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, assign) EmailAddressTableViewController *emailAddressTableViewController;
@property (assign) NSMutableArray *emailAddressItems;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *button;

- (id)initWithEmailAddressItemsArray:(NSMutableArray *)itemArray;
- (void)textFieldDoneEditing:(id)sender;
- (void)addContact:(id)sender;
- (IBAction)toggleEdit;

@end
