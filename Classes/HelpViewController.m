//
//  HelpViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/14/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpDetailViewController.h"
#import "StopwatchAppDelegate.h"

@implementation HelpViewController

@synthesize helpTableViewController;
@synthesize appDelegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	helpTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UIView* helpTableView = helpTableViewController.view;
    helpTableView.translatesAutoresizingMaskIntoConstraints = NO;
    //helpTableView.tag = @"helpTableView";
    
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(helpTableView, bottomSeparatorImageView);
    
	[self.view addSubview:helpTableViewController.tableView];
	
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[helpTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[helpTableView]|" options:0 metrics:nil views:views]];
    
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
	helpTableViewController.tableView.delegate = self;
	helpTableViewController.tableView.dataSource = self;
	
	helpTableViewController.tableView.scrollEnabled = NO;
	helpTableViewController.tableView.allowsSelection = YES;
	
	self.navigationItem.title = NSLocalizedString(@"Help", nil);
}

- (void)dealloc
{
	[helpTableViewController release];
	
	helpTableViewController = nil;
	
    [super dealloc];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Help Topics";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *HelpCellIdentifier = @"HelpCellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:HelpCellIdentifier];
	
    if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HelpCellIdentifier] autorelease];
    }
	
	UIImage *tabBarIconImage = nil;
	UILabel *topicLabel = nil;
	
	switch (indexPath.row)
	{
		case 0:
			tabBarIconImage = [UIImage imageNamed:@"splitwatch.png"];
			topicLabel = [[UILabel alloc] init];
			topicLabel.text = NSLocalizedString(@"Splitwatch", nil);
			break;
		case 1:
			tabBarIconImage = [UIImage imageNamed:@"multiwatch.png"];
			topicLabel = [[UILabel alloc] init];
			topicLabel.text = NSLocalizedString(@"Multiwatch", nil);
			break;
		case 2:
			tabBarIconImage = [UIImage imageNamed:@"history03.png"];
			topicLabel = [[UILabel alloc] init];
			topicLabel.text = NSLocalizedString(@"History", nil);
			break;			
		case 3:
			tabBarIconImage = [UIImage imageNamed:@"settings02.png"];
			topicLabel = [[UILabel alloc] init];
			topicLabel.text = NSLocalizedString(@"Settings", nil);
			break;			
		default:
			break;
	}
	
	UIImageView *accImageView = [[UIImageView alloc] initWithImage:tabBarIconImage];
	accImageView.frame = CGRectMake(25, 15, 30, 30);
	[cell addSubview:accImageView];
	[accImageView release];
	
	topicLabel.frame = CGRectMake(70, 20, 120, 20);
	[cell addSubview:topicLabel];
	[topicLabel release];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[appDelegate playClickSound];
	
	// push the help detail view controller
	HelpDetailViewController *hdvc = nil;
	
	switch (indexPath.row)
	{
		case 0:
			hdvc.navigationItem.title = @"Splitwatch";
			hdvc = [[HelpDetailViewController alloc] initWithMode:kSplitwatchMode];
			break;
		case 1:
			hdvc.navigationItem.title = @"Multiwatch";
			hdvc = [[HelpDetailViewController alloc] initWithMode:kMultiwatchMode];
			break;
		case 2:
			hdvc.navigationItem.title = @"History";
			hdvc = [[HelpDetailViewController alloc] initWithMode:kHistoryMode];
			break;
		case 3:
			hdvc.navigationItem.title = @"Settings";
			hdvc = [[HelpDetailViewController alloc] initWithMode:kSettingsMode];
			break;
		default:
			break;
	}
	
	[self.navigationController pushViewController:hdvc animated:YES];
	[hdvc release];
}

@end
