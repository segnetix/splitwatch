//
//  SplitEditViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 1/10/11.
//  Copyright 2011 SEGNETIX. All rights reserved.
//

#import "SplitEditViewController.h"
#import "Utilities.h"

//#define kSplitTimeLabelSize        24

@implementation SplitEditViewController

@synthesize event;
@synthesize lapIntervalControl;
@synthesize unitsControl;
@synthesize kiloControl;
@synthesize	furlongDisplayControl;
@synthesize splitHeader;
@synthesize splitDetailViewController;
@synthesize pickerViewController;
@synthesize pickerTopImageView;
@synthesize splitUnitLabel;
@synthesize kiloSplitLabel;
@synthesize furlongLabel;
@synthesize splitEditLabelView;

@synthesize appDelegate;

- (id)initWithEvent:(Event *)theEvent
{
	if (self = [super initWithNibName:@"SplitEditViewController" bundle:nil])
	{
		bLoading = YES;
		event = theEvent;
						  
		splitDetailViewController = [[SplitDetailViewController alloc]
									 initWithIntervalDistance:event.lapDistance
									 Units:event.iEventType
									 KiloSplits:event.bKiloSplits
									 FurlongMode:event.bFurlongMode
									 Finished:YES
									 EditMode:YES];
		
		splitDetailViewController.splits = [event getSplitData];
		splitDetailViewController.splitEditViewController = self;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
		
		// splitHeader
		splitHeader = [[SplitHeaderView alloc] init];
        splitHeader.translatesAutoresizingMaskIntoConstraints = NO;
        splitHeader.tag = @"splitHeader";
    }
	
    return self;
}

- (void)dealloc
{	
	[lapIntervalControl release];
	[unitsControl release];
	[kiloControl release];
	[furlongDisplayControl release];
	[splitDetailViewController release];
    //[pickerViewController release];
	
	lapIntervalControl = nil;
	unitsControl = nil;
	kiloControl = nil;
	furlongDisplayControl = nil;
	
	splitDetailViewController = nil;
    //pickerViewController = nil;
	
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // autolayout code
    UIView *splitDetailView = splitDetailViewController.view;
    UIView *pickerView = pickerViewController.view;
    
    splitDetailView.translatesAutoresizingMaskIntoConstraints = NO;
    pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    splitDetailView.tag = @"splitDetailView";
    pickerView.tag      = @"pickerView";
    
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *topSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    topSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(splitHeader, splitDetailView, topSeparatorImageView, bottomSeparatorImageView);
    
    [self.view addSubview:splitHeader];
    [self.view addSubview:splitDetailView];
    [self.view addSubview:topSeparatorImageView];
    [self.view addSubview:bottomSeparatorImageView];
    
    // separator line above split view header
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-215-[topSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    [topSeparatorImageView release];
    
    // separator line between split detail view and tab bar
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
    // splitHeader/splitDetailView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitHeader]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitDetailView]|" options:0 metrics:nil views:views]];
    
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-216-[splitHeader(30)][splitDetailView]-50-|" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-216-[splitHeader(20)][splitDetailView]-50-|" options:0 metrics:nil views:views]];
    }
    
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	//self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.title = @"Event Edit";
    self.view.backgroundColor = [UIColor whiteColor];
	
	// set the control states based on event
	unitsControl.selectedSegmentIndex = event.iEventType;
	
	switch (event.iEventType)
	{
		case kMetric:
			[lapIntervalControl setTitle:@"25m" forSegmentAtIndex:k25mLapInterval];
			[lapIntervalControl setTitle:@"50m" forSegmentAtIndex:k50mLapInterval];
			[lapIntervalControl setTitle:@"100m" forSegmentAtIndex:k100mLapInterval];
			[lapIntervalControl setTitle:@"200m" forSegmentAtIndex:k200mLapInterval];
			[lapIntervalControl setTitle:@"400m" forSegmentAtIndex:k400mLapInterval];
			break;
		case kEnglish:
			[lapIntervalControl setTitle:@"25y" forSegmentAtIndex:k25yLapInterval];
			[lapIntervalControl setTitle:@"50y" forSegmentAtIndex:k50yLapInterval];
			[lapIntervalControl setTitle:@"110y" forSegmentAtIndex:k110yLapInterval];
			[lapIntervalControl setTitle:@"220y" forSegmentAtIndex:k220yLapInterval];
			[lapIntervalControl setTitle:@"440y" forSegmentAtIndex:k440yLapInterval];
			break;
		case kLap:
			[lapIntervalControl setTitle:@"" forSegmentAtIndex:0];
			[lapIntervalControl setTitle:@"" forSegmentAtIndex:1];
			[lapIntervalControl setTitle:@"" forSegmentAtIndex:2];
			[lapIntervalControl setTitle:@"" forSegmentAtIndex:3];
			[lapIntervalControl setTitle:@"" forSegmentAtIndex:4];
			break;
		default:
			break;
	}
	
	switch (event.lapDistance)
	{
		case 25:	lapIntervalControl.selectedSegmentIndex = 0;	break;
		case 50:	lapIntervalControl.selectedSegmentIndex = 1;	break;
		case 100:
		case 110:	lapIntervalControl.selectedSegmentIndex = 2;	break;
		case 200:
		case 220:	lapIntervalControl.selectedSegmentIndex = 3;	break;
		case 400:
		case 440:	lapIntervalControl.selectedSegmentIndex = 4;	break;
		default:	lapIntervalControl.selectedSegmentIndex = 0;	break;
	}
	
	// save state
	intervalSelectedSegmentIndex = (int)lapIntervalControl.selectedSegmentIndex;
	
	kiloControl.on = event.bKiloSplits;
	furlongDisplayControl.enabled = furlongDisplayControl.on = event.bFurlongMode;
	
	bLoading = NO;
    
    [splitHeader setup];
    NSMutableArray *textArray = [Utilities getSplitViewHeaderArray:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongDisplayMode:event.bFurlongMode];
    [splitHeader setTextWithArray:textArray];
    
    [splitHeader release];
    [splitEditLabelView release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{	
    [super viewWillAppear:animated];
		
	[splitDetailViewController resetLapInterval:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongMode:event.bFurlongMode];
	[splitDetailViewController refreshSplitView:NO];
	
	//[self scrollToTop];
}

- (void)viewDidAppear:(BOOL)animated
{
	// enable manual split view scrolling
	
	splitDetailViewController.tableView.scrollEnabled = YES;
	[splitDetailViewController.tableView flashScrollIndicators];
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self updateEventWithChanges];
	
	[super viewWillDisappear:animated];
}

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// v1.2 - update event with changes and save changes in the Event database
- (void)updateEventWithChanges
{
	// update event with changes
	event.iEventType = (int)unitsControl.selectedSegmentIndex;
	event.bKiloSplits = kiloControl.on;
	event.bFurlongMode = furlongDisplayControl.on;
	
	if (event.iEventType == kMetric)
	{
		switch (lapIntervalControl.selectedSegmentIndex)
		{
			case 0:		event.lapDistance = 25;		break;
			case 1:		event.lapDistance = 50;		break;
			case 2:		event.lapDistance = 100;	break;
			case 3:		event.lapDistance = 200;	break;
			case 4:		event.lapDistance = 400;	break;
			default:	event.lapDistance = 25;		break;
		}
	}
	else if (event.iEventType == kEnglish)
	{
		switch (lapIntervalControl.selectedSegmentIndex)
		{
			case 0:		event.lapDistance = 25;		break;
			case 1:		event.lapDistance = 50;		break;
			case 2:		event.lapDistance = 110;	break;
			case 3:		event.lapDistance = 220;	break;
			case 4:		event.lapDistance = 440;	break;
			default:	event.lapDistance = 25;		break;
		}
	}
	else
	{
		event.lapDistance = 1;
	}
	
	event.distance = event.lapDistance * [event.splitArray count];
	event.finalTime = (NSTimeInterval)[[event.splitArray lastObject] doubleValue];
	
	// persist to the Event db
	[event updateSelfInDatabase];
}

- (void)updateSplitDetailView
{
	if (!bLoading)
	{
		[self updateEventWithChanges];
        
        NSMutableArray *textArray = [Utilities getSplitViewHeaderArray:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongDisplayMode:event.bFurlongMode];
        [splitHeader setTextWithArray:textArray];
        
		[splitDetailViewController resetLapInterval:event.lapDistance Units:event.iEventType KiloSplits:event.bKiloSplits FurlongMode:event.bFurlongMode];
		[splitDetailViewController refreshSplitView:NO];
	}
}

- (IBAction)clickedUnitsSelector:(id)sender
{
	//[appDelegate playClickSound];
	
	if (unitsControl.selectedSegmentIndex == kMetric)
	{
		[lapIntervalControl setTitle:@"25m" forSegmentAtIndex:k25mLapInterval];
		[lapIntervalControl setTitle:@"50m" forSegmentAtIndex:k50mLapInterval];
		[lapIntervalControl setTitle:@"100m" forSegmentAtIndex:k100mLapInterval];
		[lapIntervalControl setTitle:@"200m" forSegmentAtIndex:k200mLapInterval];
		[lapIntervalControl setTitle:@"400m" forSegmentAtIndex:k400mLapInterval];
		
		lapIntervalControl.enabled = YES;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = intervalSelectedSegmentIndex;
		
		furlongDisplayControl.enabled = furlongDisplayControl.on = NO;
		
		if ([lapIntervalControl selectedSegmentIndex] == k200mLapInterval)
		{
			kiloControl.enabled = YES;
		}
		else
		{
			kiloControl.enabled = NO;
			kiloControl.on = NO;
		}
	}
	else if (unitsControl.selectedSegmentIndex == kEnglish)
	{
		[lapIntervalControl setTitle:@"25y" forSegmentAtIndex:k25yLapInterval];
		[lapIntervalControl setTitle:@"50y" forSegmentAtIndex:k50yLapInterval];
		[lapIntervalControl setTitle:@"110y" forSegmentAtIndex:k110yLapInterval];
		[lapIntervalControl setTitle:@"220y" forSegmentAtIndex:k220yLapInterval];
		[lapIntervalControl setTitle:@"440y" forSegmentAtIndex:k440yLapInterval];
		
		lapIntervalControl.enabled = YES;
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = intervalSelectedSegmentIndex;
		
		kiloControl.enabled = NO;
		kiloControl.on = NO;
		
		if ([lapIntervalControl selectedSegmentIndex] == k220yLapInterval || 
			[lapIntervalControl selectedSegmentIndex] == k440yLapInterval)
		{
			furlongDisplayControl.enabled = YES;
		}
		else
		{
			furlongDisplayControl.enabled = furlongDisplayControl.on = NO;
		}
	}
	else
	{
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:0];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:1];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:2];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:3];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:4];
		
		lapIntervalControl.selectedSegmentIndex = -1;
		lapIntervalControl.enabled = NO;
		
		kiloControl.enabled = NO;
		kiloControl.on = NO;
		
		furlongDisplayControl.enabled = furlongDisplayControl.on = NO;
	}
	
	[self updateSplitDetailView];
}

- (IBAction)clickedIntervalSelector:(id)sender
{
	//[appDelegate playClickSound];
	
	if (lapIntervalControl.selectedSegmentIndex > -1)
		intervalSelectedSegmentIndex = (int)lapIntervalControl.selectedSegmentIndex;
	
	// only metric 200m setting allows kilo splits
	if ([unitsControl selectedSegmentIndex] == kMetric &&
		[lapIntervalControl selectedSegmentIndex] == k200mLapInterval)
	{
		kiloControl.enabled = YES;
	}
	else
	{
		kiloControl.enabled = NO;
		kiloControl.on = NO;
	}
	
	if ([unitsControl selectedSegmentIndex] == kEnglish &&
		([lapIntervalControl selectedSegmentIndex] == k220yLapInterval ||
		 [lapIntervalControl selectedSegmentIndex] == k440yLapInterval))
	{
		furlongDisplayControl.enabled = YES;
	}
	else
	{
		furlongDisplayControl.enabled = furlongDisplayControl.on = NO;
	}
	
	[self updateSplitDetailView];
}

- (IBAction)clickedKiloControl:(id)sender
{
	//[appDelegate playClickSound];
	
	[self updateSplitDetailView];
}

- (IBAction)clickedFurlongDisplayControl:(id)sender
{
	//[appDelegate playClickSound];
	
	[self updateSplitDetailView];
}

- (void)scrollToTop
{
	// scroll to top
	if ([event.splitArray count] > 0)
	{
		[splitDetailViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
												   atScrollPosition:UITableViewScrollPositionTop
														animated:NO];
	}
}

#pragma mark -
#pragma mark Split Edit Picker Methods

- (void)pushTimePicker:(int)row
{
    pickerViewController = [[SplitPickerViewController alloc] initWithEvent:event andRow:row];
    pickerViewController.splitDetailViewController = self.splitDetailViewController;
    [self.navigationController pushViewController:pickerViewController animated:YES];
    [pickerViewController release];
}

@end
