//
//  MultiStopwatchTableViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/15/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "MultiStopwatchTableViewController.h"
#import "MultiStopwatchViewController.h"
#import "MultiwatchCell.h"
#import "Utilities.h"
#import "Stopwatch.h"
#include <math.h>

@implementation MultiStopwatchTableViewController

@synthesize intervalDistance;
@synthesize multiStopwatchViewController;
@synthesize watches;
@synthesize multiWatchCells;
@synthesize iEventType;
@synthesize bKiloSplits;
@synthesize bFurlongMode;
@synthesize bLongPressActive;
@synthesize snapshot;
@synthesize movingFromIndexPath;
@synthesize sourceIndexPath;
@synthesize displayLink;
@synthesize longPressGestureRecognizer;

static CGFloat kListViewScrollRate =  8.0;
static CGFloat kScrollZoneHeight = 44.0;

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
		
		self.tableView.scrollEnabled = YES;
        self.tableView.bounces = NO;
		
		self.tableView.backgroundColor = [UIColor whiteColor];
		self.tableView.allowsSelection = NO;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
        // set up long press gesture recognizer for the cell move functionality
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(longPressAction:)];
        [self.tableView addGestureRecognizer:longPressGestureRecognizer];
        
        // this is so we don't drop the start/stop/lap/reset events if they are set to start on lift
        longPressGestureRecognizer.cancelsTouchesInView = NO;
        
        bLongPressActive = NO;
        
		self.multiStopwatchViewController = multiStopwatchVC;
		[self resetLapInterval:distance eventType:eventType kiloSplits:kiloSplits furlongMode:furlongMode];
    }
	
    return self;
}

- (void)dealloc
{
	[watches release];
    [multiWatchCells release];
    [longPressGestureRecognizer release];
    [sourceIndexPath release];
    [movingFromIndexPath release];
    [snapshot release];
    [displayLink release];
    
	watches = nil;
    multiWatchCells = nil;
    longPressGestureRecognizer = nil;
    sourceIndexPath = nil;
    movingFromIndexPath = nil;
    snapshot = nil;
    displayLink = nil;
    
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
        MultiwatchCell *cell = nil;
        
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
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultiwatchCell" owner:self options:nil];
        
        for (id obj in nib) {
            if ([obj isKindOfClass:[MultiwatchCell class]]) {
                cell = (MultiwatchCell *)obj;
                [cell initialize];
            }
        }
        
        // link the watch and cell
        if (cell != nil) {
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
		
        // TESTING ONLY!!!
        //watch.lapTime -= 3600.0 * 10.0;
        //watch.startTime -= 3600.0 * 10.0;
        
		for (NSNumber *split in splitData) {
			[watch addSplit:[split doubleValue]];
		}
		
		watch.bTimerRunning = (watch.startTime > 0 && watch.stopTime == 0);
		
		if (watch.bTimerRunning) {
			[watch startRunningTimer];
		}
		
		[watches addObject:watch];
		[watch release];
        
        // create multiwatch cell and add to the array
        MultiwatchCell *cell = nil;
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MultiwatchCell" owner:self options:nil];
        
        for (id obj in nib) {
            if ([obj isKindOfClass:[MultiwatchCell class]]) {
                cell = (MultiwatchCell *)obj;
                [cell initialize];
            }
        }
        
        // link the watch and cell
        if (cell != nil) {
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
#pragma mark Long Press Move Methods

// handle cell move on long press
- (void)longPressAction:(UILongPressGestureRecognizer*)gesture
{
    //let state: UIGestureRecognizerState = gesture.state
    CGPoint location = [gesture locationInView:self.tableView];
    CGPoint touchLocationInWindow = [self.tableView convertPoint:location toView:self.tableView.window];
    CGFloat touchLocationInFrameY = touchLocationInWindow.y - self.view.frame.origin.y;
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    // check that press is within the central drag area (and not in start/stop/lap/reset button area)
    MultiwatchCell *cell = (MultiwatchCell *)[multiWatchCells objectAtIndex:indexPath.row];
    int startStopButtonRightLimit = cell.startStopButton.frame.size.width + cell.startStopButton.frame.origin.x;
    int lapResetButtonLeftLimit = cell.lapResetButton.frame.origin.x;
    
    if (location.x < startStopButtonRightLimit || location.x > lapResetButtonLeftLimit) {
        longPressGestureRecognizer.enabled = NO;
        longPressGestureRecognizer.enabled = YES;
        return;
    }
    
    // check if we need to end scrolling
    if (location.y <= 0) {
        // if we moved above the table view then set the destination to the top cell and end the long press
        if (bLongPressActive) {
            NSIndexPath *topCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self longPressEnded:topCellIndexPath location:location];
        }
        return;
    }
    
    // check if we need to scroll tableView
    if (touchLocationInFrameY > self.tableView.bounds.size.height - kScrollZoneHeight) {
        // need to scroll down
        if (displayLink == nil) {
            displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollDownLoop)];
            displayLink.frameInterval = 1;
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            //NSLog(@"displayLink started 1");
        }
    } else if (touchLocationInFrameY < kScrollZoneHeight) {
        // need to scroll up
        if (displayLink == nil) {
            displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollUpLoop)];
            displayLink.frameInterval = 1;
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            //NSLog(@"displayLink started 2");
        }
    } else if (displayLink != nil) {
        // check if we need to cancel a current scroll update because the touch moved out of scroll area
        if (touchLocationInFrameY <= (self.tableView.bounds.size.height - kScrollZoneHeight)) {
            [displayLink invalidate];
            displayLink = nil;
            //NSLog(@"displayLink canceled 3");
        } else if (touchLocationInFrameY >= kScrollZoneHeight) {
            [displayLink invalidate];
            displayLink = nil;
            //NSLog(@"displayLink canceled 4");
        }
    }
    
    // if indexPath is null then we took our dragged cell some direction off the table
    if (indexPath == nil) {
        if (gesture.state != UIGestureRecognizerStateCancelled) {
            gesture.enabled = NO;
            gesture.enabled = YES;
            [self longPressEnded:movingFromIndexPath location:location];
        }
        return;
    }
    
    // handle gesture states
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self longPressBegan:indexPath location:location];
            break;
        case UIGestureRecognizerStateChanged:
            [self longPressMoved:indexPath location:location];
            break;
        case UIGestureRecognizerStateEnded:
            [self longPressEnded:indexPath location:location];
            break;
        default:
            //NSLog(@"move default");
            break;
    }
}

-(void)longPressBegan:(NSIndexPath*)indexPath location:(CGPoint)location
{
    //NSLog(@"move began");
    
    bLongPressActive = YES;
    
    // create a snapshot of the moving cell
    MultiwatchCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.snapshot = [self snapshotFromView:cell];
    sourceIndexPath = [indexPath copy];
    movingFromIndexPath = [indexPath copy];
    
    // create snapshot for long press cell moving
    __block CGPoint center = cell.center;
    snapshot.center = center;
    snapshot.alpha = 0.0;
    [self.tableView addSubview:snapshot];
    
    // animate the snapshot cell
    [UIView animateWithDuration:0.25 animations:^{
        // code for animation
        center.y = location.y;
        self.snapshot.center = center;
        self.snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.snapshot.alpha = 0.7;
        cell.alpha = 0.0;
    } completion:^(BOOL finished) {
        //code for completion
        cell.hidden = YES;      // hides the real cell while moving
        //NSLog(@"%@ hidden", cell.runnersNameLabel.text);
    }];
}

-(void)longPressMoved:(NSIndexPath*)indexPath location:(CGPoint)location
{
    if (indexPath == nil || movingFromIndexPath == nil || snapshot == nil || location.y <= 0) {
        //NSLog(@"longPressMoved early return...");
        return;
    }
    
    CGPoint center = snapshot.center;
    center.y = location.y;
    snapshot.center = center;
    
    // check if destination is valid then move the cell in the tableView
    if (movingFromIndexPath.row != indexPath.row) {
        // ... move the rows
        [self.tableView moveRowAtIndexPath:movingFromIndexPath toIndexPath:indexPath];
        
        // ... and update movingFromIndexPath so it is in sync with UI changes
        [movingFromIndexPath release];
        movingFromIndexPath = [indexPath copy];
    } else {
        //NSLog(@"longPressMoved - from == to  %li", (long)indexPath.row);
    }
}

-(void)longPressEnded:(NSIndexPath*)indexPath location:(CGPoint)location
{
    //NSLog(@"move ended");
    
    bLongPressActive = NO;
    
    // cancel any scroll loop
    [displayLink invalidate];
    displayLink = nil;
    //NSLog(@"displayLink canceled 5");
    
    if (indexPath == nil || snapshot == nil || sourceIndexPath == nil) {
        //NSLog(@"******* early return in longPressEnded...");
        return;
    }
    
    // finalize list data with new location for srcIndexObj
    CGPoint center = snapshot.center;
    center.y = location.y;
    snapshot.center = center;
    
    // check if destination is different from source and valid
    if (indexPath != sourceIndexPath) {
        // we are moving an item
        [self.tableView beginUpdates];
        
        // move the cell position in the data array
        NSUInteger fromRow = [sourceIndexPath row];
        NSUInteger toRow = [indexPath row];
        
        // update multi watch cell order
        id cell = [[multiWatchCells objectAtIndex:fromRow] retain];
        [multiWatchCells removeObject:cell];
        [multiWatchCells insertObject:cell atIndex:toRow];
        [cell release];
        
        // update watch array
        id watch = [[watches objectAtIndex:fromRow] retain];
        [watches removeObject:watch];
        [watches insertObject:watch atIndex:toRow];
        [watch release];
        
        [self.tableView endUpdates];
    }
    
    // clean up any snapshot views or displayLink scrolls
    MultiwatchCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.alpha = 0.0;
    
    // animate the snapshot cell
    [UIView animateWithDuration:0.25 animations:^{
        // code for animation
        if (cell != nil) {
            self.snapshot.center = cell.center;
        }
        self.snapshot.transform = CGAffineTransformIdentity;
        self.snapshot.alpha = 0.0;
        
        // undo fade out
        cell.alpha = 1.0;
    } completion:^(BOOL finished) {
        //code for completion
        cell.hidden = NO;
        //NSLog(@"%@ unhidden", cell.runnersNameLabel.text);
        [sourceIndexPath release];
        sourceIndexPath = nil;
        [snapshot removeFromSuperview];
        snapshot = nil;
        [self.tableView reloadData];
    }];
    
    [movingFromIndexPath release];
    movingFromIndexPath = nil;
}

- (UIView*)snapshotFromView:(UIView*)inputView
{
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView drawViewHierarchyInRect:inputView.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshotView = [[[UIImageView alloc] initWithImage:image] autorelease];
    snapshotView.layer.masksToBounds = NO;
    snapshotView.layer.cornerRadius = 0.0;
    snapshotView.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshotView.layer.shadowRadius = 5.0;
    snapshotView.layer.shadowOpacity = 0.3;
    snapshotView.layer.opacity = 0.6;
    
    return snapshotView;
}

- (void)scrollUpLoop
{
    //NSLog(@"scrollUpLoop...");
    CGPoint currentOffset = self.tableView.contentOffset;
    
    if (currentOffset.y <= 0.0) {
        return;
    }
    
    int newOffsetY = currentOffset.y - kListViewScrollRate;
    CGPoint location = [longPressGestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    [self.tableView setContentOffset:CGPointMake(currentOffset.x, newOffsetY) animated:NO];
    
    if (indexPath != nil) {
        [self longPressMoved:indexPath location:location];
        //prevLocation = location;
    }
}

- (void)scrollDownLoop
{
    //NSLog(@"scrollDownLoop...");
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat frameHeight = self.tableView.frame.size.height;
    CGPoint currentOffset = self.tableView.contentOffset;
    
    if (currentOffset.y >= contentHeight - frameHeight) {
        return;
    }
    
    int newOffsetY = currentOffset.y + kListViewScrollRate;
    CGPoint location = [longPressGestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    [self.tableView setContentOffset:CGPointMake(currentOffset.x, newOffsetY) animated:NO];
    
    if (indexPath != nil) {
        [self longPressMoved:indexPath location:location];
    }
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
    if (IPAD) {
        return 92;
    } else {
        return 66;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultiwatchCell *cell = nil;
    
    // just return the cell from the multiWatchCells array
    cell = (MultiwatchCell *)[multiWatchCells objectAtIndex:indexPath.row];
    
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

