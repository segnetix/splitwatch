//
//  EmailAddressViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 1/31/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import "EmailAddressViewController.h"
#import "EmailAddressTableViewController.h"
#import "StopwatchAppDelegate.h"

@implementation EmailAddressViewController

@synthesize emailTextField;
@synthesize emailAddressTableViewController;
@synthesize emailAddressItems;
@synthesize appDelegate;
@synthesize button;
@synthesize label;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithEmailAddressItemsArray:(NSMutableArray *)itemArray
{
    if (self = [super init])
	{
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		emailAddressItems = itemArray;
		
		// label
		//label = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, 226, 24)];
        label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = NSLocalizedString(@"Add contacts to email list:", nil);
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor blackColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        //label.tag = @"label";
		
		// Add contact button
		button = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
		//button.frame = CGRectMake(274, 16, 29, 29);
		//[button setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		button.backgroundColor = [UIColor clearColor];
		[button addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        //button.tag = @"button";
		
		// emailTextField
		//emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 62, 280, 31)];
        emailTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		emailTextField.clearsOnBeginEditing = YES;
		emailTextField.borderStyle = UITextBorderStyleRoundedRect;
		[emailTextField setDelegate:self];
		emailTextField.returnKeyType = UIReturnKeyDone;
		[emailTextField addTarget:self action:@selector(textFieldBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
		[emailTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
		emailTextField.clearsOnBeginEditing = YES;
		emailTextField.clearButtonMode = UITextFieldViewModeAlways;
        emailTextField.translatesAutoresizingMaskIntoConstraints = NO;
        //emailTextField.tag = @"emailTextField";
		
        // emailAddressTableViewController
		emailAddressTableViewController = [[EmailAddressTableViewController alloc] initWithEmailAddressViewController:self];
		//emailAddressTableViewController.view.frame = CGRectMake(20, 102, 280, 340);
        emailAddressTableViewController.view.backgroundColor = [UIColor clearColor];
        emailAddressTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

		self.navigationItem.title = NSLocalizedString(@"Email Setup", nil);
    }
	
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
	//UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEdit)];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationItem.rightBarButtonItem.action = @selector(toggleEdit);
	self.navigationItem.rightBarButtonItem.target = self;
	
	self.view.backgroundColor = [UIColor whiteColor];
	//self.view.backgroundColor = [UIColor blackColor];
	
	emailAddressTableViewController.tableView.scrollEnabled = NO;
	
    [self.view addSubview:label];
    [self.view addSubview:button];
    [self.view addSubview:emailTextField];
    [self.view addSubview:emailAddressTableViewController.view];
    
    UIView* emailAddressTable = emailAddressTableViewController.view;
    //emailAddressTable.tag = @"emailAddressTable";

    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *topSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    topSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(label, button, emailTextField, emailAddressTable, topSeparatorImageView, bottomSeparatorImageView);
    
    [self.view addSubview:topSeparatorImageView];
    [topSeparatorImageView release];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label][button(29)]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[emailTextField]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[emailAddressTable]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-72-[label(24)]-[emailTextField(31)]-16-[topSeparatorImageView(1)][emailAddressTable]-50-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-72-[button]" options:0 metrics:nil views:views]];
    
    // tab bar separator
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
    [label release];
    [button release];
    [emailTextField release];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
}

- (void)dealloc
{
	//[emailAddressTableViewController release];
    /*
    [emailTextField release];
    [button release];
    [label release];
    
    emailTextField = nil;
    button = nil;
    label = nil;
     */
    
    [super dealloc];
}

- (void)textFieldBeginEditing:(id)sender
{
	//[appDelegate playClickSound];
}

- (void)textFieldDoneEditing:(id)sender
{	
	//[appDelegate playClickSound];
	
	// add the text to our emailAddressItems array
	NSString *text = emailTextField.text;
	
	if (text.length > 0)
	{
		[emailAddressItems addObject:text];
		[self.emailAddressTableViewController.tableView reloadData];
	}
	
	[sender resignFirstResponder];
}

- (IBAction)toggleEdit
{
	//[appDelegate playClickSound];
	
	// toggle editing state
	[emailAddressTableViewController.tableView setEditing:!emailAddressTableViewController.tableView.editing animated:YES];
	
	if (emailAddressTableViewController.tableView.editing)
	{
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		self.navigationItem.rightBarButtonItem.title = @"Done";
	}
	else
	{
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		self.navigationItem.rightBarButtonItem.title = @"Edit";
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.emailTextField = nil;
	self.emailAddressTableViewController = nil;
    [super viewDidUnload];
}

- (void)addContact:(id)sender
{
	//[appDelegate playClickSound];
    
    // init the people picker here - but wait to display until called
    ABPeoplePickerNavigationController *peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerController.peoplePickerDelegate = self;
    
    [self presentViewController:peoplePickerController animated:YES completion:nil];
    
    [peoplePickerController release];
}

#pragma mark -
#pragma mark People Picker

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    //[appDelegate playClickSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    if (multi != nil)
    {
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multi, identifier);
        
        if (email != nil)
        {
            //NSLog(@"email: %@", email);
            [emailAddressItems addObject:email];
            [self.emailAddressTableViewController.tableView reloadData];
            [email release];
        }
        
        [(id)multi release];
    }
    
    //return YES;
    
    //[self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}

/*
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    if (multi != nil)
    {
        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(multi, identifier);
        
        if (email != nil)
        {
            NSLog(@"email: %@", email);
            [emailAddressItems addObject:email];
            [self.emailAddressTableViewController.tableView reloadData];
            [email release];
        }
        
        [(id)multi release];
    }
    
    return YES;
}
*/
@end
