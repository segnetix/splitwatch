//
//  AboutViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/14/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "AboutViewController.h"
#import "StopwatchAppDelegate.h"

static sqlite3_stmt *count_statement = nil;
static sqlite3_stmt *delete_statement = nil;

@implementation AboutViewController

@synthesize versionLabel;
@synthesize timingEventCountLabel;
@synthesize splitCountLabel;
@synthesize dbFileSizeLabel;
@synthesize dbVersionLabel;
@synthesize clearTimingDataButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// get app Event database
	StopwatchAppDelegate *appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
	database = [appDelegate getEventDatabase];
	
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(bottomSeparatorImageView);
    
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
	// display version
	versionLabel.text = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)dealloc
{	
	self.versionLabel = nil;
	self.timingEventCountLabel = nil;
	self.splitCountLabel = nil;
	self.dbFileSizeLabel = nil;
	self.dbVersionLabel = nil;
	
    [clearTimingDataButton release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateDatabaseStats];
	
	[super viewWillAppear:animated];
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
    [super viewDidUnload];
}

- (void)updateDatabaseStats
{
    // display database stats
    timingEventCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self getCountFrom:@"Event"]];
    splitCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self getCountFrom:@"Split"]];
    
    // db file size
    StopwatchAppDelegate *appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    double dFileSizeInKB = [appDelegate getSqliteFileSize] / 1024.0;
    dbFileSizeLabel.text = [NSString stringWithFormat:@"%u KB", (int)dFileSizeInKB];
    
    // v1.2 - db version
    dbVersionLabel.text = [appDelegate getDatabaseVersion];
}

// returns the row count from the given table
- (NSInteger)getCountFrom:(NSString *)tableName
{
	NSInteger count = 0;
	
	char sql[64] = "SELECT COUNT(*) FROM ";
	strncat(sql, [tableName UTF8String], [tableName length]);
	
	if (count_statement == nil)
	{
		if (sqlite3_prepare_v2(database, sql, -1, &count_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"ERROR: Failed to prepare Event insert statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
		
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &count_statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		//NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
	}
	
	// step through the result set rows (one per event)
	if (sqlite3_step(count_statement) == SQLITE_ROW)
	{
		count = sqlite3_column_int(count_statement, 0);
	}
	
	sqlite3_finalize(count_statement);
		
	return count;
}

- (IBAction)clearTimingData:(id)sender
{
    // are you sure you want to delete?
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete all Splitwatch timing data?"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user authorized a full data delete
    if (buttonIndex == 1)
    {
        char sql1[64] = "DELETE FROM Split";
        char sql2[64] = "DELETE FROM Event";
        char sql3[64] = "VACUUM";
        
        /*
        if (delete_statement == nil)
        {
            if (sqlite3_prepare_v2(database, sql1, -1, &delete_statement, NULL) != SQLITE_OK)
            {
                NSAssert1(0, @"ERROR: Failed to prepare Event insert statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        */
        
        // DELETE FROM Split
        if (sqlite3_prepare_v2(database, sql1, -1, &delete_statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            //NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
        }
        
        // execute the sql statement
        if (sqlite3_step(delete_statement) == SQLITE_DONE)
        {
            NSLog(@"DELETE FROM Split -- success!");
        }
        
        sqlite3_reset(delete_statement);
        
        // DELETE FROM Event
        if (sqlite3_prepare_v2(database, sql2, -1, &delete_statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            //NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
        }
        
        // execute the sql statement
        if (sqlite3_step(delete_statement) == SQLITE_DONE)
        {
            NSLog(@"DELETE FROM Event -- success!");
        }
        
        sqlite3_reset(delete_statement);
        
        // VACUUM the database
        if (sqlite3_prepare_v2(database, sql3, -1, &delete_statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            //NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
        }
        
        // execute the sql statement
        if (sqlite3_step(delete_statement) == SQLITE_DONE)
        {
            NSLog(@"VACUUM -- success!");
        }

        sqlite3_finalize(delete_statement);
        
        [self updateDatabaseStats];
    }
}

@end
