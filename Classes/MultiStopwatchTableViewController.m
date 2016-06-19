//
//  MultiStopwatchTableViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/15/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "MultiStopwatchTableViewController.h"
#import "MultiStopwatchViewController.h"
#import "MultiStopwatchCell.h"
#import "Utilities.h"
#import "Stopwatch.h"

@implementation MultiStopwatchTableViewController

@synthesize intervalDistance;
//@synthesize nextWatchIndexForLapEvent;
@synthesize multiStopwatchViewController;
@synthesize watches;
@synthesize multiWatchCells;
@synthesize iEventType;
@synthesize bKiloSplits;
@synthesize bFurlongMode;

- (id)initWithIntervalDistance:(NSInteger)distance
				   eventType:(int)eventType
					kiloSplits:(BOOL)kiloSplits
				   furlongMode:(BOOL)furlongMode
  multiStopwatchViewController:(MultiStopwatchViewController *)multiStopwatchVC
{
    if (self = [super initWithStyle:UITableViewStylePlain])
	{
		watches = [[NSMutableArray alloc] init];
        multiWatchCells = [[NSMutableArray alloc] init];
		//nextWatchIndexForLapEvent = 0;
		
		self.tableView.scrollEnabled = YES;
        self.tableView.bounces = NO;
		
		//self.view.backgroundColor = [UIColor colorWithRed:20 green:40 blue:60 alpha:1];
		self.tableView.backgroundColor = [UIColor whiteColor];
		self.tableView.allowsSelection = NO;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		self.multiStopwatchViewController = multiStopwatchVC;
		[self resetLapInterval:distance eventType:eventType kiloSplits:kiloSplits furlongMode:furlongMode];
    }
	
    return self;
}

- (void)dealloc
{
	[watches release];
    [multiWatchCells release];
    
	watches = nil;
    multiWatchCells = nil;
    
    [super dealloc];
}

- (void)resetLapInterval:(NSInteger)distance eventType:(int)eventType kiloSplits:(BOOL)kiloSplits furlongMode:(BOOL)furlongMode
{
	intervalDistance = distance;
	iEventType = eventType;
	bKiloSplits = kiloSplits;
	bFurlongMode = furlongMode;
	
	for (Stopwatch *watch in watches)
	{
		watch.intervalDistance = self.intervalDistance;
		watch.iEventType = self.iEventType;
	}
}

- (void)setupWatchesWithRunnerNames:(NSArray *)namesArray EventName:(NSString *)eventName
{
	[watches removeAllObjects];
    [multiWatchCells removeAllObjects];
	
	for (NSString *name in namesArray)
	{
		Stopwatch *watch = [[Stopwatch alloc] initWithMultiStopwatchTableViewController:self eventType:iEventType kiloSplits:bKiloSplits furlongMode:bFurlongMode];
        MultiStopwatchCell *cell = nil;
        
		// trim any long strings
		if (name.length > 50)
			watch.runnerName = [name substringToIndex:50];
		else
			watch.runnerName = name; //[name copy];				// v1.2 memory leak fix
		
		if (eventName.length > 50)
			watch.eventName = [eventName substringToIndex:50];
		else
			watch.eventName = eventName; //[eventName copy];	// v1.2 memory leak fix
		
        // add watch to array and release
		watch.intervalDistance = self.intervalDistance;
		[watches addObject:watch];
		[watch release];
        
        // create multiwatch cell and add to the array
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultiStopwatchCell" owner:self options:nil];
        
        for (id obj in nib)
        {
            if ([obj isKindOfClass:[MultiStopwatchCell class]])
            {
                cell = (MultiStopwatchCell *)obj;
                [cell initialize];
            }
        }
        
        // link the watch and cell
        if (cell != nil)
        {
            watch.stopwatchCell = cell;
            cell.watch = watch;
            cell.runnersNameLabel.text = watch.runnerName;
            
            [cell additionalSetup];
            [multiWatchCells addObject:cell];
        }
	}
	
	[self.tableView reloadData];
}

- (NSMutableArray *)getWatchStateData
{
	NSMutableArray *watchArray = [[[NSMutableArray alloc] init] autorelease];
	
	for (Stopwatch *watch in watches)
	{
		NSArray *keys = [NSArray arrayWithObjects:@"RunnerName",
												  @"EventName",
												  @"StartTime",
												  @"StopTime",
												  @"ElapsedTime",
												  @"LapTime",
												  @"PreviousLapTime",
												  @"LapCount",
												  @"IntervalDistance",
												  @"SplitData", nil];
		
		NSString *runnerName = watch.runnerName;
		NSString *eventName = watch.eventName;
		NSNumber *startTime = [NSNumber numberWithDouble:watch.startTime];
		NSNumber *stopTime = [NSNumber numberWithDouble:watch.stopTime];
		NSNumber *elapsedTime = [NSNumber numberWithDouble:watch.elapsedTime];
		NSNumber *lapTime = [NSNumber numberWithDouble:watch.lapTime];
		NSNumber *previousLapTime = [NSNumber numberWithDouble:watch.previousLapTime];
		NSNumber *lapCount = [NSNumber numberWithInt:(int)watch.lapCount];
		NSNumber *intervalDist = [NSNumber numberWithInt:(int)watch.intervalDistance];
		
		NSArray *objects = [NSArray arrayWithObjects:runnerName, eventName, startTime, stopTime, elapsedTime, lapTime, previousLapTime, lapCount, intervalDist, watch.splits, nil];
		
		NSDictionary *watchDataDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
		
		[watchArray addObject:watchDataDictionary];
		[watchDataDictionary release];
	}
	
	return watchArray;
}

- (void)setWatchStateData:(NSArray *)watchDataArray
{
	[watches removeAllObjects];
	
	for (NSDictionary *dataDictionary in watchDataArray)
	{
		NSString *runnerName = [dataDictionary objectForKey:@"RunnerName"];
		NSString *eventName = [dataDictionary objectForKey:@"EventName"];
		NSNumber *startTime = [dataDictionary objectForKey:@"StartTime"];
		NSNumber *stopTime = [dataDictionary objectForKey:@"StopTime"];
		NSNumber *elapsedTime = [dataDictionary objectForKey:@"ElapsedTime"];
		NSNumber *lapTime = [dataDictionary objectForKey:@"LapTime"];
		NSNumber *previousLapTime = [dataDictionary objectForKey:@"PreviousLapTime"];
		NSNumber *lapCount = [dataDictionary objectForKey:@"LapCount"];
		NSNumber *intervalDist = [dataDictionary objectForKey:@"IntervalDistance"];
		NSMutableArray *splitData = [dataDictionary objectForKey:@"SplitData"];
		
		Stopwatch *watch = [[Stopwatch alloc] initWithMultiStopwatchTableViewController:self
                                                                              eventType:iEventType
                                                                             kiloSplits:bKiloSplits
                                                                            furlongMode:bFurlongMode];
		
		watch.runnerName = runnerName;
		watch.eventName = eventName;
		watch.startTime = [startTime doubleValue];
		watch.stopTime = [stopTime doubleValue];
		watch.elapsedTime = [elapsedTime doubleValue];
		watch.lapTime = [lapTime doubleValue];
		watch.previousLapTime = [previousLapTime doubleValue];
		watch.lapCount = [lapCount intValue];
		watch.intervalDistance = [intervalDist intValue];
		
		for (NSNumber *split in splitData)
		{
			[watch addSplit:[split doubleValue]];
		}
		
		watch.bTimerRunning = (watch.startTime > 0 && watch.stopTime == 0);
		
		if (watch.bTimerRunning)
		{
			[watch startRunningTimer];
		}
		
		[watches addObject:watch];
		[watch release];
        
        // create multiwatch cell and add to the array
        MultiStopwatchCell *cell = nil;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultiStopwatchCell" owner:self options:nil];
        
        for (id obj in nib)
        {
            if ([obj isKindOfClass:[MultiStopwatchCell class]])
            {
                cell = (MultiStopwatchCell *)obj;
                [cell initialize];
            }
        }
        
        // link the watch and cell
        if (cell != nil)
        {
            watch.stopwatchCell = cell;
            cell.watch = watch;
            cell.runnersNameLabel.text = watch.runnerName;
            
            [cell additionalSetup];
            [multiWatchCells addObject:cell];
        }

	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//self.view.backgroundColor = [UIColor greenColor];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
#pragma mark Watch Methods

- (void)aWatchStarted:(Stopwatch *)watch
{	
	// ignoring the input watch
	
	// tell main watch to start if necessary
	[multiStopwatchViewController startMainWatch];
}

- (void)aWatchStopped:(Stopwatch *)watch
{
	// ignoring the input watch
	
	// any watches running...?
	for (Stopwatch *watch in watches)
	{
		if (watch.bTimerRunning)
			return;
	}
	
	// no watches are running so stop the main watch
	[multiStopwatchViewController stopMainWatch];
}

- (void)aWatchReset:(Stopwatch *)watch
{
	// ignoring the input watch
	
	// any watches not yet reset...?
	for (Stopwatch *watch in watches)
	{
		if (watch.startTime != 0)
			return;
	}
	
	// all watches are now reset so clear the main watch
	[multiStopwatchViewController resetMainClock];
}

/*
 - (void)aWatchLap:(Stopwatch *)watch
 {
 
 }
*/

// commits all multiwatch event data to the database
// if there are no running watches
- (void)addAllEventsToDatabase
{
	// if no watches are running...
	for (Stopwatch *watch in watches)
	{
		if (watch.bTimerRunning)
			return;
	}
	
	// delay the database commit to give all labels
	// a chance to complete their refresh
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
									 target: self
								   selector: @selector(commitWatchesToDatabase)
								   userInfo: nil
									repeats: NO];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

// this is called after the delay timer fires
// giving all the displays a change to
// update before doing this task
- (void)commitWatchesToDatabase
{
	for (Stopwatch *watch in watches)
	{
		[watch addNewEventToDatabase];
	}
}

- (void)startAllWatches:(NSTimeInterval)time
{
	//nextWatchIndexForLapEvent = 0;
	
	for (Stopwatch *watch in watches)
	{
		if (!watch.bTimerRunning)
            [watch.stopwatchCell startStopButtonPressed:nil];
	}
}

- (void)stopAllWatches:(NSTimeInterval)time
{
	for (Stopwatch *watch in watches)
	{
		if (watch.bTimerRunning)
		{
            [watch.stopwatchCell startStopButtonPressed:nil];
		}
	}
}

- (void)resetAllWatches
{
    int cellCount = 0;
    
	for (Stopwatch *watch in watches)
	{
		if (!watch.bTimerRunning)
		{
            cellCount++;
            [watch.stopwatchCell lapResetButtonPressed:nil];
		}
	}
}

- (void)setWatchButtonBehavior
{
	for (Stopwatch *watch in watches)
	{
        [watch.stopwatchCell setWatchButtonBehavior];
	}
}

// returns YES if all watches are reset
- (BOOL)allWatchesReset
{
	for (Stopwatch *watch in watches)
	{
		if (![watch isReset])
			return NO;
	}
	
	return YES;
}

/*
 // This was for an early interface feature where the operator would have
 // a single Lap button in Multiwatch mode, and that button would cycle
 // through the currently running watches and assign a split.
 // It was dropped before the initial release.
- (void)lapHitForNextWatch
{	
	// find the next running watch and call the lapResetButtonPressed method on its cell
	for (int i=0; i<watches.count; i++)
	{
		int index = (int)nextWatchIndexForLapEvent + i;
		
		if (index >= watches.count)
		{
			index -= watches.count;
		}
		
		Stopwatch *watch = (Stopwatch *)[watches objectAtIndex:index];
		
		if (watch.bTimerRunning)
		{
			[watch.stopwatchCell lapResetButtonPressed:nil];
			
			// set next watch index
			nextWatchIndexForLapEvent++;
			if (nextWatchIndexForLapEvent >= watches.count)
			{
				nextWatchIndexForLapEvent = 0;
			}
			
			return;
		}
	}
}
*/

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return watches.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 66;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    // OLD dequeue cell code from v1.2 and earlier...
    static NSString *CellIdentifier = @"MultiStopwatchCellIdentifier";
    
    MultiStopwatchCell *cell = (MultiStopwatchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultiStopwatchCell" owner:self options:nil];
		
		for (id obj in nib)
		{
			if ([obj isKindOfClass:[MultiStopwatchCell class]])
			{
				cell = (MultiStopwatchCell *)obj;
				[cell initialize];
			}
		}
    }
	*/
    
    MultiStopwatchCell *cell = nil;
    
    // just return the cell from the multiWatchCells array
    cell = (MultiStopwatchCell *)[multiWatchCells objectAtIndex:indexPath.row];
    
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}
*/

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end

