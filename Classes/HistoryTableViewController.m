//
//  HistoryTableViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 2/13/10.

//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "Utilities.h"
#import "HistoryCell.h"
#import "StopwatchAppDelegate.h"

#define kMaxStaticHistoryRows	9

@implementation HistoryTableViewController

@synthesize tableItems;
@synthesize historyViewController;
@synthesize settingsViewController;
@synthesize bDisplayEvents;
@synthesize filterSelection;
@synthesize appDelegate;

- (id)initWithHistoryViewController:(HistoryViewController *)theHistoryVC SettingsViewController:(SettingsViewController *)theSettingsVC;
{
    if (self = [super initWithStyle:UITableViewStylePlain])
	{
		tableItems = [[NSMutableArray alloc] initWithCapacity:100];

		historyViewController = theHistoryVC;
		settingsViewController = theSettingsVC;
		
        // set cell styles
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.backgroundColor = [UIColor whiteColor];
		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
		
		// get the event database from the application delegate
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
		bDisplayEvents = YES;
		filterSelection = 0;

		historyViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
	
    return self;
}

- (void)dealloc
{
	[tableItems release];
	
	tableItems = nil;
	
	[super dealloc];
}

- (void)viewDidLoad
{
    self.tableView.tableFooterView = [[[UIView alloc] init] autorelease];
    
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)addEvent:(Event *)event atFront:(BOOL)front reloadData:(BOOL)reload
{
	if (front)
	{
		[tableItems insertObject:event atIndex:0];
	}
	else
	{
		[tableItems addObject:event];		
	}
	
	if (reload)
	{
		[self.tableView reloadData];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// no need write the event db as events are written when created
}

- (void)scrollToTop
{
	// scroll to top
	if ([tableItems count] > 0)
	{
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
													atScrollPosition:UITableViewScrollPositionTop
															animated:NO];
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	if ([tableItems count] > kMaxStaticHistoryRows)
		self.tableView.scrollEnabled = YES;
	else
		self.tableView.scrollEnabled = NO;
	
    return [tableItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IPAD) {
        return kiPadHistoryTableViewCellHeight;
    } else {
        return kiPhoneHistoryTableViewCellHeight;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *EventCellIdentifier = @"EventCellIdentifier";

    // create an Event cell (HistoryCell) for the history table
    HistoryCell *cell = (HistoryCell *)[tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:self options:nil];
        
        for (id obj in nib)
        {
            if ([obj isKindOfClass:[HistoryCell class]])
            {
                cell = (HistoryCell *)obj;
                
                // NOTE: The reuse identifier for a nib-based cell is set in IB in the Identifier field.
                
                // perform any set up common to all cells
                [cell additionalSetup];
            }
        }
    }
    
    if (bDisplayEvents)
    {
        // Event-level cell setup
        NSInteger row = indexPath.row;
        
        NSArray *eventInfo = [tableItems objectAtIndex:row];
        
        cell.dateLabel.text = [eventInfo objectAtIndex:1];
        cell.eventLabel.text = [eventInfo objectAtIndex:2];
        cell.timeLabel.text = [eventInfo objectAtIndex:3];
        cell.nameLabel.text = [eventInfo objectAtIndex:4];
        
        cell.textLabel.text = @"";

    }
    else
    {
        // Group-level cell setup
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        if (IPAD) {
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:24];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        } else {
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:18];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        cell.dateLabel.text  = @"";
        cell.eventLabel.text = @"";
        cell.timeLabel.text  = @"";
        cell.nameLabel.text  = @"";
        
        cell.textLabel.text = (NSString *)[tableItems objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[appDelegate playClickSound];
	
	if (bDisplayEvents)
	{
		// push the event view controller for selected event
		// get the EventNum for this selection
		NSArray *eventInfo = [tableItems objectAtIndex:indexPath.row];
		NSNumber *eventNum = [eventInfo objectAtIndex:0];
		
		// create an Event using the EventNum
		Event *event = [[Event alloc] initWithEventNum:[eventNum intValue]];
		
		// pass event to the HistoryViewController
		[historyViewController eventSelected:event];
		[event release];
	}
	else
	{
		// repopulate the table view with the filtered events
		if (filterSelection > 0 && filterSelection < 5)
		{
			// clear sortSegmentedControl selection
			historyViewController.sortSegmentedControl.selectedSegmentIndex = -1;
			
			// get filter where clause from the tableItems array then clear the array
			NSString *filterClause = [[tableItems objectAtIndex:indexPath.row] retain];
			bDisplayEvents = YES;
			
			// returns event info based on the given selection filter
			appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
			NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnSelection:filterSelection withFilter:filterClause];
			
			// clear and refill tableItems with selected events
			[tableItems removeAllObjects];
			[tableItems addObjectsFromArray:eventInfoArray];
			
			[self.tableView reloadData];
			[self.tableView flashScrollIndicators];
			
			// this was added -- do I need to retain/release???]
			[filterClause release];
		}
        
        //historyViewController.sortSegmentedControl.selectedSegmentIndex = self.filterSelection;
	}
	
	[self scrollToTop];
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row%2 == 0)
	{
        UIColor *altCellColor = [UIColor whiteColor];
        cell.backgroundColor = altCellColor;
    }
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// delete associated event(s)
	if (bDisplayEvents)
	{
		// delete the selected event
		// get the EventNum for this selection
		NSArray *eventInfo = [tableItems objectAtIndex:indexPath.row];
		NSNumber *evntNum = [eventInfo objectAtIndex:0];
		
		// instance an Event using the EventNum so we can delete it from the database
		Event *event = [[Event alloc] initWithEventNum:[evntNum intValue]];
		
		[event deleteSelfFromDatabase];
		[event release];
	}
	else
	{
		// delete the selected group of events
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSString *filter = [tableItems objectAtIndex:indexPath.row];
		NSArray *eventInfoArray = [appDelegate getEventInfoArrayBasedOnSelection:filterSelection withFilter:filter];
		
		for (NSArray *eventInfo in eventInfoArray)
		{
			// get the EventNum for this selection
			NSNumber *evntNum = [eventInfo objectAtIndex:0];
			
			// create an Event using the EventNum
			Event *event = [[Event alloc] initWithEventNum:[evntNum intValue]];
			
			[event deleteSelfFromDatabase];
			[event release];
		}
	}
	
	// remove object from tableItems and row from tableView
	[self.tableItems removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

// populate tableItems with objects from the given selection
- (void)groupEventsBySelection:(NSInteger)selection
{	
	// don't process if just clearing the sortSegmentedControl selection (set to -1)
	if (selection < 0)
		return;
	
	// if given selection is greater than kRunnerName (4) then use current selection
	if (selection > kRunnerName)
		selection = filterSelection;
	
	// clear current event array and reload from the event database with current sort selection
	[tableItems removeAllObjects];
	filterSelection = selection;
	
	char sql[250];
	sqlite3_stmt *statement;
	
	switch (filterSelection) {
		case kAll:			// All - populate the table view with info for a single event
			//strcpy(sql, "SELECT EventNum FROM Event ORDER BY EventDateTime DESC");
			strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event ORDER BY EventDateTime DESC");
			bDisplayEvents = YES;
			break;
		case kDate:			// Date - populate with groups
			strcpy(sql, "SELECT DISTINCT date(EventDateTime) FROM Event ORDER BY EventDateTime DESC");
			bDisplayEvents = NO;
			break;
		case kDistance:		// Distance - populate with groups
			strcpy(sql, "SELECT DISTINCT EventDistance, EventType, FurlongMode FROM Event ORDER BY EventDistance");
			bDisplayEvents = NO;
			break;
		case kEventName:	// EventName - populate with groups
			strcpy(sql, "SELECT DISTINCT EventName FROM Event ORDER BY EventName");
			bDisplayEvents = NO;
			break;
		case kRunnerName:	// RunnerName - populate with groups
			strcpy(sql, "SELECT DISTINCT RunnerName FROM Event ORDER BY RunnerName");
			bDisplayEvents = NO;
			break;
		default:
			//NSLog(@"ERROR: Filter selection out of range.");
			return;
			break;
	}
	
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		//NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
	}
	
	int tempcount = 0;
	
	// step through the result set rows (one per event)
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		if (bDisplayEvents)
		{
			NSMutableArray *eventInfo = [[NSMutableArray alloc] initWithCapacity:5];
			
			// we are displaying a single event, so pull event info from the query result and put into the tableItems array
			NSNumber *eventNum = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
			NSString *dateStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSNumber *distanceNumber = [NSNumber numberWithInt:sqlite3_column_double(statement, 2)];
			NSNumber *finalTimeNumber = [NSNumber numberWithDouble:sqlite3_column_double(statement, 3)];
			NSString *runnerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
			int eventType = (int)(sqlite3_column_int(statement, 5));
			int lapDistance = (int)(sqlite3_column_int(statement, 6));
			int furlongMode = (int)(sqlite3_column_int(statement, 7));
			
			// need to convert these values
			NSString *distanceString = [Utilities stringFromDistance:[distanceNumber intValue] Units:eventType ShowSplitTag:NO Interval:lapDistance FurlongDisplayMode:furlongMode];
			NSString *finalTimeString = [Utilities shortFormatTime:[finalTimeNumber doubleValue] precision:2];
			
			[eventInfo addObject:eventNum];
			[eventInfo addObject:dateStr];
			[eventInfo addObject:distanceString];
			[eventInfo addObject:finalTimeString];
			[eventInfo addObject:runnerName];
			
			// add eventInfo to the tableItem array
			[tableItems addObject:eventInfo];
			[eventInfo release];
		}
		else
		{
			// we are displaying groups so query for groups and populate group array
			NSString *cellText;
			
			if (filterSelection == kDistance)
			{
				int eventDistance = sqlite3_column_int(statement, 0);
				int eventType = sqlite3_column_int(statement, 1);
				int furlongMode = sqlite3_column_int(statement, 2);

				if (furlongMode == YES)
				{
					cellText = [Utilities stringFromDistance:eventDistance
													   Units:eventType
												ShowSplitTag:NO
													Interval:220
										  FurlongDisplayMode:YES];
				}
				else
				{
					cellText = [Utilities stringFromDistance:eventDistance
													   Units:eventType
												ShowSplitTag:NO
													Interval:0
										  FurlongDisplayMode:NO];
				}
				
				tempcount++;
			}
			else
			{
				cellText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
			}
			
			[tableItems addObject:cellText];
		}
	}
	
	sqlite3_finalize(statement);
	
	[self.tableView reloadData];
	[self.tableView flashScrollIndicators];
}

@end
