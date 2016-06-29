//
//  ReportSelectorViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "ReportSelectorViewController.h"
#import "ReportSelectorCell.h"
#import "ReportSelectionListTableViewController.h"
#import "StopwatchAppDelegate.h"

@implementation ReportSelectorViewController

@synthesize reportSelectorTableViewController;
@synthesize athlete;
@synthesize event;
@synthesize date;
@synthesize distance;
@synthesize generateButton;
@synthesize appDelegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // ReportSelectorTableViewController
    reportSelectorTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UIView* reportSelectorTableView = reportSelectorTableViewController.view;
    reportSelectorTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:reportSelectorTableViewController.tableView];
    
    // Generate button
    generateButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];      // autorelease button
    [generateButton addTarget:self action:@selector(generate) forControlEvents:UIControlEventTouchUpInside];
    [generateButton setTitle:@"Generate" forState:UIControlStateNormal];
    [generateButton setTintColor:self.view.tintColor];
    generateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:generateButton];
    
    // constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(reportSelectorTableView, generateButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=50)-[generateButton(120)]-(>=50)-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[generateButton(36)]-64-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reportSelectorTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[reportSelectorTableView(290)]" options:0 metrics:nil views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:generateButton
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.f constant:0.f]];

    
    reportSelectorTableViewController.tableView.delegate = self;
    reportSelectorTableViewController.tableView.dataSource = self;
    reportSelectorTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    reportSelectorTableViewController.tableView.scrollEnabled = NO;
    reportSelectorTableViewController.tableView.allowsSelection = YES;
    
    self.navigationItem.title = @"Email Report";
}

- (void)dealloc
{
    [reportSelectorTableViewController release];
    [generateButton release];
    
    reportSelectorTableViewController = nil;
    generateButton = nil;
    
    [super dealloc];
}

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
#pragma mark TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    switch (section) {
        case 0: rows = 0; break;
        case 1: rows = 4; break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Select events for report:";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReportSelectorCellIdentifier = @"ReportSelectorCellIdentifier";
    
    // create an Event cell (HistoryCell) for the history table
    ReportSelectorCell *cell = (ReportSelectorCell *)[tableView dequeueReusableCellWithIdentifier:ReportSelectorCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ReportSelectorCell" owner:self options:nil];
        
        for (id obj in nib) {
            if ([obj isKindOfClass:[ReportSelectorCell class]]) {
                cell = (ReportSelectorCell *)obj;
                // NOTE: The reuse identifier for a nib-based cell is set in IB in the Identifier field.
                // perform any set up common to all cells
            }
        }
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.selectorLabel.text = @"Athlete";
            cell.selectionLabel.text = self.athlete;
            break;
        case 1:
            cell.selectorLabel.text = @"Event";
            cell.selectionLabel.text = self.event;
            break;
        case 2:
            cell.selectorLabel.text = @"Date";
            cell.selectionLabel.text = self.date;
            break;
        case 3:
            cell.selectorLabel.text = @"Distance";
            cell.selectionLabel.text = self.distance;
            break;
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [appDelegate playClickSound];
    
    NSString *selectedValue = [self getValueForSelector:(int)indexPath.row+1];
    
    // push the help detail view controller
    ReportSelectionListTableViewController *rsltvc = [[ReportSelectionListTableViewController alloc] initWithMode:indexPath.row+1 selection:selectedValue ReportSelectorViewController:self];
    
    [self.navigationController pushViewController:rsltvc animated:YES];
    [rsltvc release];
}

- (void)setValue:(NSString*)value forSelector:(int)selector
{
    switch (selector) {
        case kAthleteSelectorMode:
            self.athlete = value;
            break;
        case kEventSelectorMode:
            self.event = value;
            break;
        case kDateSelectorMode:
            self.date = value;
            break;
        case kDistanceSelectorMode:
            self.distance = value;
            break;
    }
    
    [reportSelectorTableViewController.tableView reloadData];
}

- (NSString*)getValueForSelector:(int)selector
{
    switch (selector) {
        case kAthleteSelectorMode:
            return self.athlete;
            break;
        case kEventSelectorMode:
            return self.event;
            break;
        case kDateSelectorMode:
            return self.date;
            break;
        case kDistanceSelectorMode:
            return self.distance;
            break;
    }
    
    return @"";
}

- (void)generate
{
    NSLog(@"generate report for %@ %@ %@ %@", self.athlete, self.event, self.date, self.distance);
    
}

@end
