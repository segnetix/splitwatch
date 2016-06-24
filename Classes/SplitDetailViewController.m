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
	
	cell.lapColumn.text = [self lapTextForRow:indexPath.row forDisplayMode:displayMode];
	cell.timeColumn.text = [self timeTextForRow:indexPath.row forDisplayMode:displayMode];
	cell.splitColumn1.text = [self splitTextForRow:indexPath.row Column:1 forDisplayMode:displayMode];
	cell.splitColumn2.text = [self splitTextForRow:indexPath.row Column:2 forDisplayMode:displayMode];
	cell.splitColumn3.text = [self splitTextForRow:indexPath.row Column:3 forDisplayMode:displayMode];
	cell.splitColumn4.text = [self splitTextForRow:indexPath.row Column:4 forDisplayMode:displayMode];
		
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

#pragma mark -
#pragma mark Cell Text Methods

- (NSString *)lapTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode
{
    return [Utilities lapTextForRow:row
                     forDisplayMode:mode
                    withSplitsCount:(int)splits.count
                   intervalDistance:(int)intervalDistance
                              units:iUnits
                        furlongMode:bFurlongMode];
}

- (NSString *)timeTextForRow:(NSInteger)row forDisplayMode:(NSInteger)mode
{
	NSString *cellText = @"";
	
	if (splits.count > 0)
	{	
		if (mode == kDisplayMode_Normal)
		{
			// lap time
			NSNumber *nSplit = [splits objectAtIndex:row];
			NSTimeInterval split = [nSplit doubleValue];
			
			// if split > 1 hour, drop precision to 1
			// if split > 10 hours, drop precision to 0 (no fractional seconds)
			if (split < 3600)
				cellText = [Utilities shortFormatTime:split precision:2];
			else if (split < 36000)
				cellText = [Utilities shortFormatTime:split precision:1];
			else
				cellText = [Utilities shortFormatTime:split precision:0];
		}
		else if (mode == kDisplayMode_Space /*&& iUnits < kLap*/)
		{
			cellText = @"";
		}
		else if (mode == kDisplayMode_Last_Header /*&& iUnits < kLap*/)			// v1.2
		{
			cellText = [Utilities stringFromDistance:intervalDistance
											   Units:iUnits
										   ShowMiles:NO
										ShowSplitTag:NO
											Interval:(int)intervalDistance
								  FurlongDisplayMode:bFurlongMode];
		}
		else if (mode == kDisplayMode_Last_Split /*&& iUnits < kLap*/)			// v1.2
		{
			cellText = [self lastSplitTextForColumn:0];
		}
		else if (mode == kDisplayMode_Avg_Split /*&& iUnits < kLap*/)			// v1.2
		{
            cellText = [Utilities avgSplit:splits forColumn:1];
		}
		else if (mode == kDisplayMode_Min_Split /*&& iUnits < kLap*/)			// v1.2
		{
			cellText = [Utilities minSplit:splits forColumn:1];
		}
		else if (mode == kDisplayMode_Max_Split /*&& iUnits < kLap*/)			// v1.2
		{
			cellText = [Utilities maxSplit:splits forColumn:1];
		}
	}
	
	return cellText;
}

- (NSString *)splitTextForRow:(NSInteger)row Column:(NSInteger)column forDisplayMode:(NSInteger)mode
{
	NSString *cellText = @"";
	NSInteger modValue;
	
	switch (column)
	{
		case 1: modValue = 1; break;
		case 2: modValue = 2; break;
		case 3: modValue = 4; break;
		case 4: modValue = (bKiloSplits) ? 5 : 8; break;
		default: modValue = 99; break;
	}
	
	if (splits.count > 0)
	{
		if (mode == kDisplayMode_Normal)
		{
			if (iUnits == kLap && column >= 2)
			{
				return cellText;
			}
				
			// lap count
			int lapCount = (int)(row + 1);
			
			if (lapCount % modValue == 0)
			{
				// lap time
				NSNumber *nSplit = [splits objectAtIndex:row];
				NSTimeInterval split = [nSplit doubleValue];
				
				// interval time
				NSTimeInterval intervaltime = split;
				
				if (lapCount > modValue)
				{
					NSNumber *nPrevSplit = [splits objectAtIndex:row - modValue];
					intervaltime = split - [nPrevSplit doubleValue];
				}
				
				// if split > 1 hour, drop precision to 1
				// if split > 10 hours, drop precision to 0 (no fractional seconds)
				if (intervaltime < 3600)
					cellText = [Utilities shortFormatTime:intervaltime precision:1];
				else if (intervaltime < 36000)
					cellText = [Utilities shortFormatTime:intervaltime precision:1];
				else
					cellText = [Utilities shortFormatTime:intervaltime precision:0];
			}
		}
		else if (mode == kDisplayMode_Space)
		{
			cellText = @"";
		}
		else if (mode == kDisplayMode_Last_Header)
		{
			if (column < splits.count)
				cellText = [Utilities stringFromDistance:((column + 1) * intervalDistance)
												   Units:iUnits
											   ShowMiles:NO
											ShowSplitTag:NO
												Interval:(int)intervalDistance
									  FurlongDisplayMode:bFurlongMode];
		}
		else if (mode == kDisplayMode_Last_Split)
		{
			cellText = [self lastSplitTextForColumn:column];
		}
        else if (mode == kDisplayMode_Avg_Split && splits.count - 1 > column)
        {
            cellText = [Utilities avgSplit:splits forColumn:column + 1];
        }
        else if (mode == kDisplayMode_Max_Split && splits.count - 1 > column)
        {
            cellText = [Utilities maxSplit:splits forColumn:column + 1];
        }
        else if (mode == kDisplayMode_Min_Split && splits.count - 1 > column)
        {
            cellText = [Utilities minSplit:splits forColumn:column + 1];
        }
		else
		{
			cellText = @"";
		}
	}
	
	return cellText;
}

- (NSString *)lastSplitTextForColumn:(NSInteger)column 
{
	NSString *cellText = @"";
	
	if (splits.count > column)
	{
		// bump column as we start with last split column 2 (last split 1 is handled in timeTextForRow:)
		column++;
		
		int lastSplitIndex = (int)(splits.count - 1);
		
		// final time
		NSNumber *lastSplit = [splits lastObject];
		NSTimeInterval finalTime = [lastSplit doubleValue];
		
		// interval time
		NSTimeInterval intervaltime = 0;
		
		if (column == splits.count)
		{
			intervaltime = finalTime;
		}
		else
		{
			NSNumber *prevSplit = [splits objectAtIndex:lastSplitIndex - column];
			intervaltime = finalTime - [prevSplit doubleValue];
		}
		
		// if split > 1 hour, drop precision to 1
		// if split > 10 hours, drop precision to 0 (no fractional seconds)
		if (intervaltime < 3600)
			cellText = [Utilities shortFormatTime:intervaltime precision:1];
		else if (intervaltime < 36000)
			cellText = [Utilities shortFormatTime:intervaltime precision:1];
		else
			cellText = [Utilities shortFormatTime:intervaltime precision:0];
	}
	
	return cellText;
}

- (NSString *)splitHTMLTextForRow:(NSInteger)row
{
	NSString *splitRowText = @"";
	
	if (splits.count > 0)
	{
		splitRowText = [splitRowText stringByAppendingString:@"<tr class='splitData' align='right'>"];
		splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self lapTextForRow:row forDisplayMode:kDisplayMode_Normal]];
        splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self timeTextForRow:row forDisplayMode:kDisplayMode_Normal]];
		splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 1 forDisplayMode:kDisplayMode_Normal]];
		splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 2 forDisplayMode:kDisplayMode_Normal]];
		splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 3 forDisplayMode:kDisplayMode_Normal]];
		splitRowText = [splitRowText stringByAppendingFormat:@"<td>%@</td>", [self splitTextForRow:row Column: 4 forDisplayMode:kDisplayMode_Normal]];
		splitRowText = [splitRowText stringByAppendingString:@"</tr>"];
	}
	
	return splitRowText;	
}

// v1.2 - added rowCount and handling for lap mode and furlong mode
- (NSString *)lastSplitHeaderHTMLText:(int)rowCount
{
	//if (iUnits == kLap)
	//	return @"";
	
	NSString *lastSplitHeaderText = @"<tr><td> </td></tr><tr class='lastSplitDataHeader' style='font-weight:bold;' align='right'>";
	
    if (rowCount > 1)
        lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>Last:</td>"];
    else
        lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td> </td>"];
	
	// rolled up split header
	if (iUnits == kMetric)
	{
        if (rowCount == 2)
        {
            switch (intervalDistance) {
                case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td>",  25,  50]; break;
                case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td>",  50, 100]; break;
                case 100:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td>", 100, 200]; break;
                case 200:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td>", 200, 400]; break;
                case 400:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td>", 400, 800]; break;
                default:	break;
            }
        }
		else if (rowCount == 3)
		{
			switch (intervalDistance) {
				case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75]; break;
				case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150]; break;
				case 100:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300]; break;
				case 200:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600]; break;
				case 400:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200]; break;
				default:	break;
			}
		}
		else if (rowCount == 4)
		{
			switch (intervalDistance) {
				case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75,  100]; break;
				case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150,  200]; break;
				case 100:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300,  400]; break;
				case 200:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600,  800]; break;
				case 400:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200, 1600]; break;
				default:	break;
			}
		}
		else
		{
			switch (intervalDistance) {
				case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75,  100,  125]; break;
				case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150,  200,  250]; break;
				case 100:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  300,  400,  500]; break;
				case 200:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  600,  800, 1000]; break;
				case 400:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1200, 1600, 2000]; break;
				default:	break;
			}
		}
	}
	else if (iUnits == kEnglish)
	{
		if (bFurlongMode && (intervalDistance == 220 || intervalDistance == 440))
		{
			if (intervalDistance == 220)
			{
				if (rowCount == 3)
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8"];
				else if (rowCount == 4)
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8", @"1/2"];
				else
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"3/8", @"1/2", @"5/8"];
			}
			else
			{
				if (rowCount == 3)
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4"];
				else if (rowCount == 4)
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4", @"Mile"];
				else
					lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"3/4", @"Mile", @"1-1/4"];
			}
		}
		else
		{
			if (rowCount == 3)
			{
				switch (intervalDistance) {
					case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75]; break;
					case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150]; break;
					case 110:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330]; break;
					case 220:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660]; break;
					case 440:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 440, 880, 1320]; break;
					default:	break;
				}
			}
			else if (rowCount == 4)
			{
				switch (intervalDistance) {
					case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75, 100]; break;
					case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150, 200]; break;
					case 110:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330, 440]; break;
					case 220:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660, 880]; break;
					case 440:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td>", 440, 880, 1320, @"Mile"]; break;
					default:	break;
				}
			}
			else
			{
				switch (intervalDistance) {
					case  25:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,   75, 100,  125]; break;
					case  50:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  150, 200,  250]; break;
					case 110:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220,  330, 440,  550]; break;
					case 220:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 220, 440,  660, 880, 1100]; break;
					case 440:	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td><td>%@</td>", 440, 880, 1320, @"Mile", @"Mile-1/4"]; break;
					default:	break;
				}
			}
		}
	}
	else if (iUnits == kLap)
	{
		if (rowCount == 3)
		{
			lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3];
		}
		else if (rowCount == 4)
		{
			lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3, 4];
		}
		else
		{
			lastSplitHeaderText = [lastSplitHeaderText stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 1, 2, 3, 4, 5];
		}
	}
	
	lastSplitHeaderText = [lastSplitHeaderText stringByAppendingString:@"</tr>"];
	
	return lastSplitHeaderText;	
}

- (NSString *)lastSplitHTMLText
{
	//if (iUnits == kLap)
	//	return @"";
	
	NSString *lastSplitRowText = @"<tr class='lastSplitData' align='right'>";
	
	if (splits.count > 0)
	{
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td></td>"];
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td>%@</td>", [self lastSplitTextForColumn: 0]];
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td>%@</td>", [self lastSplitTextForColumn: 1]];
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td>%@</td>", [self lastSplitTextForColumn: 2]];
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td>%@</td>", [self lastSplitTextForColumn: 3]];
		lastSplitRowText = [lastSplitRowText stringByAppendingFormat:@"<td>%@</td>", [self lastSplitTextForColumn: 4]];
		lastSplitRowText = [lastSplitRowText stringByAppendingString:@"</tr>"];
	}
	
	return lastSplitRowText;	
}

- (NSString *)getSplitHTMLDataString
{
	NSString *splitDataStr = @"";
	
	splitDataStr = [splitDataStr stringByAppendingString:@"<table id='splitData' cellpadding='5'>"];
	splitDataStr = [splitDataStr stringByAppendingString:@"<tr id='headers' style='font-weight:bold;' align='center'>"];
	splitDataStr = [splitDataStr stringByAppendingString:@"<td align='right'>Split</td><td>Time</td>"];
	
	// rolled up split header
	if (iUnits == kMetric)
	{
		if (bKiloSplits)
		{
			switch (intervalDistance) {
				case  25:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,  100,  200]; break;
				case  50:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  200,  400]; break;
				case 100:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  400,  800]; break;
				case 200:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  800, 1000]; break;
				case 400:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1000, 1600]; break;
				default:	break;
			}
		}
		else
		{
			switch (intervalDistance) {
				case  25:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50,  100,  200]; break;
				case  50:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100,  200,  400]; break;
				case 100:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 100, 200,  400,  800]; break;
				case 200:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 200, 400,  800, 1600]; break;
				case 400:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 400, 800, 1600, 3200]; break;
				default:	break;
			}
		}
	}
	else if (iUnits == kEnglish)
	{
		if (bFurlongMode && (intervalDistance == 220 || intervalDistance == 440))
		{
			if (intervalDistance == 220)
				splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/8", @"1/4", @"1/2", @"Mile"];
			else
				splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%@</td><td>%@</td><td>%@</td><td>%@</td>",  @"1/4", @"1/2", @"Mile", @"2-Mile"];
		}
		else
		{
			switch (intervalDistance)
			{
				case  25:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  25,  50, 100, 200]; break;
				case  50:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>",  50, 100, 200, 400]; break;
				case 110:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%u</td>", 110, 220, 440, 880]; break;
				case 220:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%u</td><td>%@</td>", 220, 440, 880, @"Mile"]; break;
				case 440:	splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%u</td><td>%u</td><td>%@</td><td>%@</td>", 440, 880, @"Mile", @"2-Mile"]; break;
				default:	break;
			}
		}
	}
	else if (iUnits == kLap)
	{
		splitDataStr = [splitDataStr stringByAppendingFormat:@"<td>%@</td>",  @"Interval"];
	}

	// rolled up split rows
	for (int row = 0; row < splits.count; row++)
	{
		splitDataStr = [splitDataStr stringByAppendingString:[self splitHTMLTextForRow:row]];
	}
	
	// write last header and split rows
    // v1.2 - write Min, Max, Avg split summary
    // v2.0 - summaries for all distances
    if (splits.count > 1)
    {
        splitDataStr = [splitDataStr stringByAppendingFormat:@"%@", [self lastSplitHeaderHTMLText:(int)splits.count]];
        splitDataStr = [splitDataStr stringByAppendingFormat:@"%@", [self lastSplitHTMLText]];
		splitDataStr = [splitDataStr stringByAppendingString:@"<tr><td align='right'> </td></tr>"];
        
        splitDataStr = [splitDataStr stringByAppendingString:@"<td><b>Min:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            splitDataStr = [splitDataStr stringByAppendingFormat:@"<td align='right'>%@</td>", [Utilities minSplit:splits forColumn:column]];
        
        splitDataStr = [splitDataStr stringByAppendingString:@"<tr></tr><td><b>Max:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            splitDataStr = [splitDataStr stringByAppendingFormat:@"<td align='right'>%@</td>", [Utilities maxSplit:splits forColumn:column]];
        
        splitDataStr = [splitDataStr stringByAppendingString:@"<tr></tr><td><b>Avg:</b></td>"];
        for (int column = 1; column <= splits.count && column <= 5; column++)
            splitDataStr = [splitDataStr stringByAppendingFormat:@"<td align='right'>%@</td>", [Utilities avgSplit:splits forColumn:column]];
	}
    
	// end table
	splitDataStr = [splitDataStr stringByAppendingString:@"</table>"];
	
	return splitDataStr;
}

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