//
//  HistoryViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewController.h"
#import "EventDetailViewController.h"
#import "Utilities.h"
#import "HistoryCell.h"
#import "StopwatchAppDelegate.h"

#define kKeepCurrentSelection 999

@implementation HistoryViewController

@synthesize historyTableViewController;
@synthesize settingsViewController;

@synthesize sortSegmentedControl;
@synthesize appDelegate;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC
{
	if (self = [super init])
	{
        settingsViewController = theSettingsVC;
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        // historyTableViewController
        historyTableViewController = [[HistoryTableViewController alloc]
                                      initWithHistoryViewController:self
                                      SettingsViewController:settingsViewController];
        
        // sortSegmentedControl
        NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Date", @"Distance", @"Event", @"Athlete", nil];
        sortSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        
        // AutoLayout setup
        UIView* historyView = historyTableViewController.view;
        historyView.tag = @"historyView";
        NSDictionary *views = NSDictionaryOfVariableBindings(historyView, sortSegmentedControl);
        
        //historyTableViewController.view.frame = CGRectMake(0, 65, 320, 300);
        [historyTableViewController groupEventsBySelection:0];
        historyView.translatesAutoresizingMaskIntoConstraints = NO;
        historyView.tag = @"historyView";
        [self.view addSubview:historyView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[historyView]|" options:0 metrics:nil views:views]];
        
        
        //sortSegmentedControl.frame = CGRectMake(0, 386, 320, 44);
        //sortSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        sortSegmentedControl.tintColor = [UIColor darkGrayColor];
        sortSegmentedControl.selectedSegmentIndex = 0;
        sortSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        sortSegmentedControl.tag = @"sortSegmentedControl";
        [sortSegmentedControl addTarget:self
                                 action:@selector(sortControlHit:)
                       forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:sortSegmentedControl];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sortSegmentedControl]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[historyView][sortSegmentedControl(44)]-50-|" options:0 metrics:nil views:views]];
        [sortSegmentedControl release];
	}
	
    return self;
}

- (void)dealloc
{
	[historyTableViewController release];
	
	[super dealloc];
}

- (void)viewDidLoad
{	
	[historyTableViewController groupEventsBySelection:0];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{	
	[historyTableViewController groupEventsBySelection:kKeepCurrentSelection];
	[historyTableViewController scrollToTop];
	
    sortSegmentedControl.selectedSegmentIndex = historyTableViewController.filterSelection;
    
	// v1.2 - for Furlong Mode
	if ([settingsViewController isSetForFurlongDisplay])
		[sortSegmentedControl setTitle:@"Horse" forSegmentAtIndex:4];
	else
		[sortSegmentedControl setTitle:@"Athlete" forSegmentAtIndex:4];
    
	[super viewWillAppear:animated];
}

- (void)addEvent:(Event *)event atFront:(BOOL)front reloadData:(BOOL)reload
{
	[historyTableViewController addEvent:event atFront:front reloadData:reload];
}

- (void)sortControlHit:(id)sender
{	
	//[appDelegate playClickSound];
	
	// redraw the HistoryTableViewController with selection
	[historyTableViewController groupEventsBySelection:sortSegmentedControl.selectedSegmentIndex];
	[historyTableViewController scrollToTop];
    
    sortSegmentedControl.selectedSegmentIndex = historyTableViewController.filterSelection;
}

// this is called from the HistoryTableViewController to push the EventDetailViewController
- (void)eventSelected:(Event *)event;
{	
	EventDetailViewController *eventDetailViewController = [[EventDetailViewController alloc]
															initWithEvent:event settingsVC:settingsViewController];
    
	[self.navigationController pushViewController:eventDetailViewController animated:YES];
	[eventDetailViewController release];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// no need write the event db as events are written when created
}

@end