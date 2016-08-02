//
//  EventDetailViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "SplitDetailViewController.h"
#import "Utilities.h"
#import "SplitEditViewController.h"
#import "StopwatchAppDelegate.h"

@implementation SplitDetailViewController

@synthesize splits;
@synthesize bFinished;
@synthesize bEditMode;
@synthesize splitEditViewController;
@synthesize appDelegate;
@synthesize bWideDisplay;
@synthesize summarySelection;
@synthesize initialHighlightRow;

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
        self.summarySelection = kNone;
        self.initialHighlightRow = -1;
        [self addObserver:self forKeyPath:@"summarySelection" options:NSKeyValueObservingOptionNew context:nil];
        
		splitEditViewController = nil;
        
		iUnits = units;
		bKiloSplits = kiloSplits;
		bFurlongMode = furlongMode;
		bFinished = finished;
		bEditMode = editMode;
		
        if (bFinished || bEditMode)
            self.tableView.allowsSelection = YES;
        else
            self.tableView.allowsSelection = NO;
        
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
		[self resetLapInterval:distance Units:iUnits KiloSplits:bKiloSplits FurlongMode:bFurlongMode];
        
        self.tableView.clearsContextBeforeDrawing = YES;
    }
    
    return self;
}

// KVO for summarySelection
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"summarySelection"]) {
        [self summarySelectionDidChange];
    }
}

- (void)dealloc
{
	[splits release];
	splits = nil;
    
    [self removeObserver:self forKeyPath:@"summarySelection"];
	
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
    self.summarySelection = kNone;
    
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

- (void)summarySelectionDidChange
{
    //NSLog(@"summarySelection changed to %i", summarySelection);
    
    if (summarySelection == kNone) {
        initialHighlightRow = -1;
    } else {
        NSInteger column = 0;
        
        if      (summarySelection == kTimeColumnMin   || summarySelection == kTimeColumnMax  )  column = 1;
        else if (summarySelection == kSplitColumn1Min || summarySelection == kSplitColumn1Max)  column = 2;
        else if (summarySelection == kSplitColumn2Min || summarySelection == kSplitColumn2Max)  column = 3;
        else if (summarySelection == kSplitColumn3Min || summarySelection == kSplitColumn3Max)  column = 4;
        else if (summarySelection == kSplitColumn4Min || summarySelection == kSplitColumn4Max)  column = 5;
        
        if (summarySelection <= kSplitColumn4Min) {
            initialHighlightRow = [Utilities minSplitRow:self.splits forColumn:column];
        } else {
            initialHighlightRow = [Utilities maxSplitRow:self.splits forColumn:column];
        }
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SplitDetailCellIdentifier";
    SplitDetailCell *cell = (SplitDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
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
	
    // edit mode cells don't need to message the splitDetailViewController
    if (bEditMode) {
        cell.splitDetailViewController = nil;
    } else {
        cell.splitDetailViewController = self;
    }
    
    // default background colors
    cell.backgroundColor = [UIColor whiteColor];
    cell.lapColumn.backgroundColor = [UIColor clearColor];
    cell.timeColumn.backgroundColor = [UIColor clearColor];
    cell.splitColumn1.backgroundColor = [UIColor clearColor];
    cell.splitColumn2.backgroundColor = [UIColor clearColor];
    cell.splitColumn3.backgroundColor = [UIColor clearColor];
    cell.splitColumn4.backgroundColor = [UIColor clearColor];
    
	// populate the cell text and background based on current display mode
	NSInteger displayMode = kDisplayMode_Normal;
    
    // write summary rows if timer is finished
    if (bFinished) {
        UIColor *HILIGHT_COLOR = [UIColor colorWithRed:0.0 green:.475 blue:1.0 alpha:0.35];
        
        if (indexPath.row == splits.count) {
            displayMode = kDisplayMode_Space;
        }
        else if (indexPath.row == (splits.count + 1)) {
            displayMode = kDisplayMode_Last_Header;
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        else if (indexPath.row == (splits.count + 2)) {
            displayMode = kDisplayMode_Last_Split;
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        else if (indexPath.row == (splits.count + 3)) {
            displayMode = kDisplayMode_Min_Split;
        }
        else if (indexPath.row == (splits.count + 4)) {
            displayMode = kDisplayMode_Max_Split;
        }
        else if (indexPath.row == (splits.count + 5)) {
            displayMode = kDisplayMode_Avg_Split;
        }
        
        // handle the min/max interval hilights
        if (summarySelection > kNone && displayMode == kDisplayMode_Normal && initialHighlightRow >= 0) {
            NSInteger finalHighlightRow = initialHighlightRow;
            
            switch (summarySelection) {
                case kSplitColumn1Min: finalHighlightRow += 1; break;
                case kSplitColumn1Max: finalHighlightRow += 1; break;
                case kSplitColumn2Min: finalHighlightRow += 2; break;
                case kSplitColumn2Max: finalHighlightRow += 2; break;
                case kSplitColumn3Min: finalHighlightRow += 3; break;
                case kSplitColumn3Max: finalHighlightRow += 3; break;
                case kSplitColumn4Min: finalHighlightRow += 4; break;
                case kSplitColumn4Max: finalHighlightRow += 4; break;
                default: break;
            }
            
            if (indexPath.row >= initialHighlightRow &&
                indexPath.row <= finalHighlightRow)
            {
                cell.lapColumn.backgroundColor = HILIGHT_COLOR;
            }
        }
        
        // handle the min/max summary label selections
        if (displayMode == kDisplayMode_Min_Split || displayMode == kDisplayMode_Max_Split) {
            // highlight a selected summary label
            if (summarySelection > kNone) {
                if ((displayMode == kDisplayMode_Min_Split && self.summarySelection <= kSplitColumn4Min) ||
                    (displayMode == kDisplayMode_Max_Split && self.summarySelection >= kTimeColumnMax))
                {
                    if (self.summarySelection == kTimeColumnMin || self.summarySelection == kTimeColumnMax)
                        cell.timeColumn.backgroundColor = HILIGHT_COLOR;
                    else if (self.summarySelection == kSplitColumn1Min || self.summarySelection == kSplitColumn1Max)
                        cell.splitColumn1.backgroundColor = HILIGHT_COLOR;
                    else if (self.summarySelection == kSplitColumn2Min || self.summarySelection == kSplitColumn2Max)
                        cell.splitColumn2.backgroundColor = HILIGHT_COLOR;
                    else if (self.summarySelection == kSplitColumn3Min || self.summarySelection == kSplitColumn3Max)
                        cell.splitColumn3.backgroundColor = HILIGHT_COLOR;
                    else if (self.summarySelection == kSplitColumn4Min || self.summarySelection == kSplitColumn4Max)
                        cell.splitColumn4.backgroundColor = HILIGHT_COLOR;
                }
            }
        }
    }
    
	cell.lapColumn.text = [Utilities lapTextForRow:indexPath.row forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode];
	cell.timeColumn.text = [Utilities timeTextForRow:indexPath.row forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode];
    cell.splitColumn1.text = [Utilities splitTextForRow:indexPath.row Column:1 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn2.text = [Utilities splitTextForRow:indexPath.row Column:2 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn3.text = [Utilities splitTextForRow:indexPath.row Column:3 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
	cell.splitColumn4.text = [Utilities splitTextForRow:indexPath.row Column:4 forDisplayMode:displayMode forSplits:splits forIntervalDistance:intervalDistance forUnits:iUnits forFurlongMode:bFurlongMode forKiloSplits:bKiloSplits];
		
    return cell;
}

- (void)processRowSelection:(NSInteger)displayMode withDistance:(NSString *)distance
{
    NSLog(@"processRowSelection: %lu withDistance: %@", (long)displayMode, distance);
}

// scroll to and flash the modified/inserted splits
- (void)flashSplitCellsInRow:(long)row
{
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    SplitDetailCell *cell = (SplitDetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell != NULL) {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.33 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            cell.lapColumn.textColor = [UIColor redColor];
            cell.timeColumn.textColor = [UIColor redColor];
            cell.splitColumn1.textColor = [UIColor redColor];
            cell.splitColumn2.textColor = [UIColor redColor];
            cell.splitColumn3.textColor = [UIColor redColor];
            cell.splitColumn4.textColor = [UIColor redColor];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.22 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                cell.lapColumn.textColor = [UIColor blackColor];
                cell.timeColumn.textColor = [UIColor blackColor];
                cell.splitColumn1.textColor = [UIColor blackColor];
                cell.splitColumn2.textColor = [UIColor blackColor];
                cell.splitColumn3.textColor = [UIColor blackColor];
                cell.splitColumn4.textColor = [UIColor blackColor];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.11 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    cell.lapColumn.textColor = [UIColor redColor];
                    cell.timeColumn.textColor = [UIColor redColor];
                    cell.splitColumn1.textColor = [UIColor redColor];
                    cell.splitColumn2.textColor = [UIColor redColor];
                    cell.splitColumn3.textColor = [UIColor redColor];
                    cell.splitColumn4.textColor = [UIColor redColor];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.22 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        cell.lapColumn.textColor = [UIColor blackColor];
                        cell.timeColumn.textColor = [UIColor blackColor];
                        cell.splitColumn1.textColor = [UIColor blackColor];
                        cell.splitColumn2.textColor = [UIColor blackColor];
                        cell.splitColumn3.textColor = [UIColor blackColor];
                        cell.splitColumn4.textColor = [UIColor blackColor];
                    });
                });
            });
        });
    }
}

@end