//
//  ReportSelectionListTableViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 6/29/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "ReportSelectionListTableViewController.h"
#import "ReportSelectorViewController.h"
#import "StopwatchAppDelegate.h"
#import "Utilities.h"

@interface ReportSelectionListTableViewController ()

@end

@implementation ReportSelectionListTableViewController

@synthesize selectorMode;
@synthesize selection;
@synthesize selections;
@synthesize reportSelectorVC;
@synthesize appDelegate;

- (id)initWithMode:(NSInteger)mode selection:(NSString*)listSelection ReportSelectorViewController:(ReportSelectorViewController *)rsvc
{
    if (self = [super init]) {
        self.selectorMode = mode;
        self.selection = listSelection;
        self.reportSelectorVC = rsvc;
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    
        // get the event database from the application delegate
        database = [appDelegate getEventDatabase];
        
        switch (self.selectorMode) {
            case kAthleteSelectorMode:
                self.navigationItem.title = @"Athlete";
                break;
            case kEventSelectorMode:
                self.navigationItem.title = @"Event";
                break;
            case kDateSelectorMode:
                self.navigationItem.title = @"Date";
                break;
            case kDistanceSelectorMode:
                self.navigationItem.title = @"Distance";
                break;
            default:
                break;
        }
        
        selections = [[NSMutableArray alloc] init];
        
        [self populateSelections];
    }
    
    return self;
}

- (void)dealloc
{
    [selections release];
    selections = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return selections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReportSelectionListReuseIdentifier = @"reportSelectionListReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportSelectionListReuseIdentifier"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReportSelectionListReuseIdentifier] autorelease];
    }
    
    cell.textLabel.text = [selections objectAtIndex:indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.selection]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)populateSelections
{
    [selections removeAllObjects];
    [selections addObject:@"All"];
    
    char sql[250];
    sqlite3_stmt *statement;
    
    switch (selectorMode) {
        case kAthleteSelectorMode:
            strcpy(sql, "SELECT DISTINCT RunnerName FROM Event ORDER BY RunnerName");
            break;
        case kEventSelectorMode:
            strcpy(sql, "SELECT DISTINCT EventName FROM Event ORDER BY EventName");
            break;
        case kDateSelectorMode:
            strcpy(sql, "SELECT DISTINCT date(EventDateTime) FROM Event ORDER BY EventDateTime DESC");
            break;
        case kDistanceSelectorMode:
            strcpy(sql, "SELECT DISTINCT EventDistance, EventType, FurlongMode FROM Event ORDER BY EventDistance");
            break;
        default:
            NSLog(@"ERROR: Filter selection out of range.");
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
        // we are displaying groups so query for groups and populate group array
        NSString *cellText;
        
        if (selectorMode == kDistanceSelectorMode)
        {
            int eventDistance = sqlite3_column_int(statement, 0);
            int eventType = sqlite3_column_int(statement, 1);
            int furlongMode = sqlite3_column_int(statement, 2);
            
            if (furlongMode == YES)
            {
                cellText = [Utilities stringFromDistance:eventDistance
                                                   Units:eventType
                                               ShowMiles:YES
                                            ShowSplitTag:NO
                                                Interval:220
                                      FurlongDisplayMode:YES];
            }
            else
            {
                cellText = [Utilities stringFromDistance:eventDistance
                                                   Units:eventType
                                               ShowMiles:YES
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
        
        [selections addObject:cellText];
    }
    
    sqlite3_finalize(statement);
    
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.reportSelectorVC setValue:[selections objectAtIndex:indexPath.row] forSelector:(int)selectorMode];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
