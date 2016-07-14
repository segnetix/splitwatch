//
//  EmailAddressTableViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 2/18/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import "EmailAddressTableViewController.h"

#define kMaxStaticLines		7

@implementation EmailAddressTableViewController

@synthesize emailAddressItems;
@synthesize emailAddressViewController;

- (id)initWithEmailAddressViewController:(EmailAddressViewController *)emailAVC;
{
    if (self = [super initWithStyle:UITableViewStylePlain])
	{		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		//[self.tableView setEditing:YES];
		//self.tableView.backgroundColor = [UIColor blackColor];
		emailAddressViewController = emailAVC;
		emailAddressItems = emailAddressViewController.emailAddressItems;
	}
	
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{	
	//self.view.backgroundColor = [UIColor colorWithRed:.5 green:.6 blue:.7 alpha:.4];
	self.view.backgroundColor = [UIColor clearColor];
    
	[super viewDidLoad];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
    [super viewDidUnload];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([emailAddressItems count] > kMaxStaticLines)
		self.tableView.scrollEnabled = YES;
	else
		self.tableView.scrollEnabled = NO;
		
	return [emailAddressItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [emailAddressItems objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    cell.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:.5 green:.6 blue:.7 alpha:.4];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
 */

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// remove object from tableItems and row from tableView
		[emailAddressItems removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }	
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	id object = [[emailAddressItems objectAtIndex:fromRow] retain];
	[emailAddressItems removeObjectAtIndex:fromRow];
	[emailAddressItems insertObject:object atIndex:toRow];
	[object release];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end

