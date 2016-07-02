//
//  EventDetailViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "SplitDetailViewController.h"
#import "Utilities.h"
#import "SplitDetailCell.h"
#import "SplitEditViewController.h"
#import "StopwatchAppDelegate.h"

@implementation SplitDetailViewController

@synthesize splits;
@synthesize bFinished;
@synthesize bEditMode;
@synthesize splitEditViewController;
@synthesize appDelegate;
@synthesize bWideDisplay;

#pragma mark -

- (id)initWithIntervalDistance:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode Finished:(BOOL)finished EditMode:(BOOL)editMode
{
    if (self = [super initWithStyle:UITableViewStylePlain])
	{
		splits = [[NSMutableArray alloc] init];
		self.tableView.allowsSelection = NO;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.tableView.backgroundColor = [UIColor whiteColor];
		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
		
		splitEditViewController = nil;
        
		iUnits = units;
		bKiloSplits = kiloSplits;
		bFurlongMode = furlongMode;
		bFinished = finished;
		bEditMode = editMode;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		if (bEditMode)
		{
			// edit mode setup
			self.tableView.allowsSelection = YES;
		}
        
		[self resetLapInterval:distance Units:iUnits KiloSplits:bKiloSplits FurlongMode:bFurlongMode];
    }
    
    self.tableView.clearsContextBeforeDrawing = YES;
    
    return self;
}

- (void)dealloc
{
	[splits release];
	
	splits = nil;
	
    [super dealloc];
}

- (void)loadView
{
	[super loadView]; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (CALayer* layer in [self.view.layer sublayers])
    {
        [layer removeAllAnimations];
    }
    
    [super viewWillDisappear:animated];
}

- (void)addSplit:(NSTimeInterval)split
{	
	[splits addObject:[NSNumber numberWithDouble:split]];
	[self refreshSplitView:YES];
}

- (void)refreshSplitView:(BOOL)scrollToLastLine
{
	[self.tableView reloadData];
	
	if (scrollToLastLine)
	{
		[self scrollToLastLine];
	}
}

- (void)scrollToTop
{
	if (splits.count > 12)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionTop
									  animated:NO];
	}
}

- (void)scrollToLastLine
{
	// scroll the last split line into view
	int lastLineIndex = (int)splits.count;
	
	if (bFinished)
		lastLineIndex += 6;
	
	if (lastLineIndex > 12)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(lastLineIndex - 1) inSection:0];
		
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionBottom
									  animated:NO];
	}
}

- (NSMutableArray *)getSplits
{
	return self.splits;
}

- (NSTimeInterval)getFinalTime
{		
	NSNumber *lastSplit = [splits lastObject];
		
	if (lastSplit != nil)
		return (NSTimeInterval)[lastSplit doubleValue];
	else
		return 0;
}

- (NSInteger)getFinalDistance
{
	return intervalDistance * splits.count;
}

- (void)clearSplits
{
	[splits removeAllObjects];
	[self.tableView reloadData];
}

- (void)resetLapInterval:(NSInteger)distance Units:(int)units KiloSplits:(BOOL)kiloSplits FurlongMode:(BOOL)furlongMode;
{
	intervalDistance = distance;
	iUnits = units;
	bKiloSplits = kiloSplits;
	bFurlongMode = furlongMode;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
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
	NSInteger rowCount = [splits count];
	
	if (bFinished && !bEditMode && splits.count > 1)
		rowCount += kSummaryLineCount;
	
	return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (bEditMode) {
        if (IPAD) {
            return 40.0;
        } else {
            return 26.0;
        }
    } else {
        if (IPAD) {
            return 30.0;
        } else {
            return 20.0;
        }
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SplitDetailCellIdentifier";
    
    SplitDetailCell *cell = (SplitDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SplitDetailCell" owner:self options:nil];
		
		for (id obj in nib) {
			if ([obj isKindOfClass:[SplitDetailCell class]]) {
				cell = (SplitDetailCell *)obj;
				
				if (bEditMode) {
					[cell additionalSetup];
				}
			}
		}
    }
	
	// populate the cell text based on current display mode
	NSInteger displayMode = kDisplayMode_Normal;
	cell.backgroundColor = [UIColor whiteColor];
    
    if (bFinished)
    {
        if (indexPath.row == splits.count)
            displayMode = kDisplayMode_Space;
        else if (indexPath.row == (splits.count + 1))
        {
            displayMode = kDisplayMode_Last_Header;
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        else if (indexPath.row == (splits.count + 2))
        {
            displayMode = kDisplayMode_Last_Split;
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        else if (indexPath.row == (splits.count + 3))
            displayMode = kDisplayMode_Min_Split;
        else if (indexPath.row == (splits.count + 4))
            displayMode = kDisplayMode_Max_Split;
        else if (indexPath.row == (splits.count + 5))
            displayMode = kDisplayMode_Avg_Split;
    }
    
	cell.lapColumn.text = [Utilities lapTextForRow:indexPath.row forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode];
	cell.timeColumn.text = [Utilities timeTextForRow:indexPath.row forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode];
    cell.splitColumn1.text = [Utilities splitTextForRow:indexPath.row Column:1 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn2.text = [Utilities splitTextForRow:indexPath.row Column:2 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn3.text = [Utilities splitTextForRow:indexPath.row Column:3 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn4.text = [Utilities splitTextForRow:indexPath.row Column:4 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
		
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (bEditMode)
	{
		//[appDelegate playClickSound];
		
		// push the split time picker
		[splitEditViewController pushTimePicker:(int)indexPath.row];
	}
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.row == 0 || indexPath.row % 2 == 0)
	if (indexPath.row == (splits.count + 1) && splits.count > 0)
    {
        //UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        //cell.backgroundColor = altCellColor;
        //cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
}
*/

// scroll to and flash the modified/inserted splits
- (void)flashSplitCellsInRow:(int)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    SplitDetailCell *cell = (SplitDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        cell.lapColumn.textColor = [UIColor redColor];
        cell.timeColumn.textColor = [UIColor redColor];
        cell.splitColumn1.textColor = [UIColor redColor];
        cell.splitColumn2.textColor = [UIColor redColor];
        cell.splitColumn3.textColor = [UIColor redColor];
        cell.splitColumn4.textColor = [UIColor redColor];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            cell.lapColumn.textColor = [UIColor blackColor];
            cell.timeColumn.textColor = [UIColor blackColor];
            cell.splitColumn1.textColor = [UIColor blackColor];
            cell.splitColumn2.textColor = [UIColor blackColor];
            cell.splitColumn3.textColor = [UIColor blackColor];
            cell.splitColumn4.textColor = [UIColor blackColor];
        });
    });
}

@end