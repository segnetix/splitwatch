//
//  MultiStopwatchSetupViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/19/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "MultiStopwatchSetupViewController.h"
#import "MultiStopwatchViewController.h"
#import "StopwatchAppDelegate.h"

#define kAthletes					  1
#define kEvents						  2
#define kiPhoneCellHeight            36
#define kiPhoneCellFontSize          24
#define kiPadCellHeight              42
#define kiPadCellFontSize            30

@implementation MultiStopwatchSetupViewController

@synthesize mainViewController;
@synthesize pickView;
@synthesize pickerToolbar;
@synthesize pickerSeparatorImageView;
@synthesize athleteField;
@synthesize eventField;
@synthesize athleteLabel;
@synthesize eventLabel;
@synthesize nameTable;
@synthesize pickEventButton;
@synthesize pickAthleteButton;
@synthesize clearAllButton;
@synthesize appDelegate;
@synthesize bCurrentlyEditing;
@synthesize keyboardHeight;
@synthesize nameArray;
@synthesize tapGesture;
@synthesize bLongPressActive;
@synthesize snapshot;
@synthesize movingFromIndexPath;
@synthesize sourceIndexPath;
@synthesize displayLink;
@synthesize longPressGestureRecognizer;

static CGFloat kListViewScrollRate =  8.0;
static CGFloat kScrollZoneHeight = 40.0;

- (id)initWithMainViewController:(MultiStopwatchViewController *)mainVC
{
	if (self = [super initWithNibName:@"MultiStopwatchSetupViewController" bundle:nil])
	{
		self.mainViewController = mainVC;
		bCurrentlyEditing = NO;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
		database = [appDelegate getEventDatabase];
        
        self.title = NSLocalizedString(@"Multiwatch Setup", nil);
        
        // this left button is just to clear the space, so only the right side Done button will appear and function
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.navigationItem.leftBarButtonItem = backBarButton;
        
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:nil action:NULL];
        self.navigationItem.rightBarButtonItem = doneBarButton;
        
        // separators
        UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
        pickerSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
        pickerSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // set target and action for Done button
        doneBarButton.target = self;
        doneBarButton.action = @selector(doneWithSetup);
        
        [backBarButton release];
        [doneBarButton release];
	}
	
	return self;
}

- (void)dealloc
{
    [athleteField release];
    athleteField = nil;
    
    [eventField release];
    eventField = nil;
    
    [athleteLabel release];
    athleteLabel = nil;
    
    [eventLabel release];
    eventLabel = nil;
    
    [nameTable release];
    nameTable = nil;
    
    [nameArray release];
    nameArray = nil;
    
    [pickEventButton release];
    pickEventButton = nil;
    
    [pickAthleteButton release];
    pickAthleteButton = nil;
    
    [clearAllButton release];
    clearAllButton = nil;
    
    [pickerDataArray release];
    pickerDataArray = nil;
    
    [displayLink release];
    displayLink = nil;
    
    //[pickView release];
    pickView = nil;
    
    //[pickerToolbar release];
    pickerToolbar = nil;
    
    appDelegate = nil;
    mainViewController = nil;
    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	pickerDataArray = [[NSMutableArray alloc] init];
    
    // setup pickView
    pickView = [[UIPickerView alloc] init];
    pickView.delegate = self;
    pickView.showsSelectionIndicator = YES;
    pickView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    pickView.translatesAutoresizingMaskIntoConstraints = NO;
    pickView.userInteractionEnabled = YES;
    //pickView.tag = @"pickView";
    [self.view addSubview:pickView];
    [pickView release];
    
    // setup pickerToolbar
    pickerToolbar = [[UIToolbar alloc] init];
    pickerToolbar.backgroundColor = [UIColor groupTableViewBackgroundColor];
    pickerToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    //pickerToolbar.tag = @"pickerToolbar";
    [self.view addSubview:pickerToolbar];
    [pickerToolbar release];
    
    // picker separator
    [self.view addSubview:pickerSeparatorImageView];
    pickerSeparatorImageView.hidden = YES;
    [pickerSeparatorImageView release];
    
    UIBarButtonItem *pickerCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(pickerCancel)];
    
    UIBarButtonItem *pickerAddButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                     target:self
                                                                                     action:@selector(pickerAdd)];
    UIBarButtonItem *flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    NSArray *items = [[[NSArray alloc] initWithObjects: flexibleSpace, pickerCancelButton, flexibleSpace, pickerAddButton, flexibleSpace, nil] autorelease];
    
    [pickerToolbar setItems:items animated:YES];
    
    // toolbar separator
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;

    // set other button target and actions
    [pickAthleteButton addTarget:self action:@selector(openPicker:) forControlEvents:UIControlEventTouchUpInside];
    [pickEventButton   addTarget:self action:@selector(openPicker:) forControlEvents:UIControlEventTouchUpInside];
    [clearAllButton   addTarget:self action:@selector(clearAll:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(pickView, pickerToolbar, pickerSeparatorImageView, bottomSeparatorImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerToolbar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerSeparatorImageView]|" options:0 metrics:nil views:views]];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-222-[pickView(216)][pickerToolbar][pickerSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-193-[pickView(162)][pickerToolbar][pickerSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    }
    
    // separator line between the multiwatches and the tab bar
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
    tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerDoubleTap)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delegate = self;
    
    [pickView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [nameTable setDataSource:self];
    [nameTable setDelegate:self];
    [nameTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // set up long press gesture recognizer for the table cell move functionality
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(longPressAction:)];
    [nameTable addGestureRecognizer:longPressGestureRecognizer];
    
    bLongPressActive = NO;
    
    pickAthleteButton.enabled = YES;
    pickEventButton.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    
	// clear text fields
	athleteField.text = @"";
	
    if (eventField.text.length == 0) {
        eventField.text = [mainViewController getEventName];
    }
    
    nameArray = [[mainViewController getNames] mutableCopy];
    
    pickView.hidden = YES;
    pickerToolbar.hidden = YES;
    pickerSeparatorImageView.hidden = YES;
    nameTable.hidden = NO;
    
    pickAthleteButton.enabled = YES;
    pickEventButton.enabled = YES;
    
	[super viewWillAppear:animated];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	self.athleteField = nil;
	self.eventField = nil;
	
	[super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
	bCurrentlyEditing = NO;
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

#pragma mark -
#pragma mark Long Press Move Methods

// handle cell move on long press
- (void)longPressAction:(UILongPressGestureRecognizer*)gesture
{
    //let state: UIGestureRecognizerState = gesture.state
    CGPoint location = [gesture locationInView:nameTable];
    CGPoint touchLocationInWindow = [nameTable convertPoint:location toView:nameTable.window];
    CGFloat touchLocationInFrameY = touchLocationInWindow.y - nameTable.frame.origin.y;
    NSIndexPath *indexPath = [nameTable indexPathForRowAtPoint:location];
    
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
    if (touchLocationInFrameY > nameTable.bounds.size.height - kScrollZoneHeight) {
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
        if (touchLocationInFrameY <= (nameTable.bounds.size.height - kScrollZoneHeight)) {
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
    UITableViewCell *cell = [nameTable cellForRowAtIndexPath:indexPath];
    self.snapshot = [self snapshotFromView:cell];
    sourceIndexPath = [indexPath copy];
    movingFromIndexPath = [indexPath copy];
    
    // create snapshot for long press cell moving
    __block CGPoint center = cell.center;
    snapshot.center = center;
    snapshot.alpha = 0.0;
    [nameTable addSubview:snapshot];
    
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
        //NSLog(@"%@ hidden", cell.textLabel.text);
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
        [nameTable moveRowAtIndexPath:movingFromIndexPath toIndexPath:indexPath];
        
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
        [nameTable beginUpdates];
        
        // move the cell position in the data array
        NSUInteger fromRow = [sourceIndexPath row];
        NSUInteger toRow = [indexPath row];
        
        // update name array
        id name = [[nameArray objectAtIndex:fromRow] retain];
        [nameArray removeObject:name];
        [nameArray insertObject:name atIndex:toRow];
        [name release];
        
        [nameTable endUpdates];
    }
    
    // clean up any snapshot views or displayLink scrolls
    UITableViewCell *cell = [nameTable cellForRowAtIndexPath:indexPath];
    
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
        //NSLog(@"%@ unhidden", cell.textLabel.text);
        [sourceIndexPath release];
        sourceIndexPath = nil;
        [snapshot removeFromSuperview];
        snapshot = nil;
        [nameTable reloadData];
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
    CGPoint currentOffset = nameTable.contentOffset;
    
    if (currentOffset.y <= 0.0) {
        return;
    }
    
    int newOffsetY = currentOffset.y - kListViewScrollRate;
    CGPoint location = [longPressGestureRecognizer locationInView:nameTable];
    NSIndexPath *indexPath = [nameTable indexPathForRowAtPoint:location];
    
    [nameTable setContentOffset:CGPointMake(currentOffset.x, newOffsetY) animated:NO];
    
    if (indexPath != nil) {
        [self longPressMoved:indexPath location:location];
        //prevLocation = location;
    }
}

- (void)scrollDownLoop
{
    //NSLog(@"scrollDownLoop...");
    CGFloat contentHeight = nameTable.contentSize.height;
    CGFloat frameHeight = nameTable.frame.size.height;
    CGPoint currentOffset = nameTable.contentOffset;
    
    if (currentOffset.y >= contentHeight - frameHeight) {
        return;
    }
    
    int newOffsetY = currentOffset.y + kListViewScrollRate;
    CGPoint location = [longPressGestureRecognizer locationInView:nameTable];
    NSIndexPath *indexPath = [nameTable indexPathForRowAtPoint:location];
    
    [nameTable setContentOffset:CGPointMake(currentOffset.x, newOffsetY) animated:NO];
    
    if (indexPath != nil) {
        [self longPressMoved:indexPath location:location];
    }
}


#pragma mark -
#pragma mark Text Field Methods

- (void)doneWithSetup
{
    //[appDelegate playClickSound];
    
    //  Send setup data back to mainVC
    [mainViewController updateFromSetupWithNames:[[nameArray copy] autorelease] andEvent:eventField.text];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)textFieldBeginEditing:(UITextField *)textField
{
	//[appDelegate playClickSound];
	
	bCurrentlyEditing = YES;
    currentEditField = textField;
    
    pickView.hidden = YES;
    pickerToolbar.hidden = YES;
    pickerSeparatorImageView.hidden = YES;
    nameTable.hidden = NO;
    
	pickAthleteButton.enabled = NO;
	pickEventButton.enabled = NO;
    
    [self.navigationController setNavigationBarHidden: NO animated:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender
{	
	//[appDelegate playClickSound];
	
    if (currentEditField == athleteField && athleteField.text.length > 0)
    {
        [nameArray addObject:athleteField.text];
        [nameTable reloadData];
        athleteField.text = @"";
        [self scrollToLastLine];
    }
    
	bCurrentlyEditing = NO;
	
	pickAthleteButton.enabled = YES;
	pickEventButton.enabled = YES;
	
	[sender resignFirstResponder];
    
    [self.navigationController setNavigationBarHidden: NO animated:YES];
}

- (IBAction)clearAll:(id)sender
{
	//[appDelegate playClickSound];
	
    if (eventField.text.length > 0 ||
        athleteField.text.length > 0 ||
        nameArray.count > 0)
    {
        // are you sure you want to delete?
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear this Multiwatch setup?"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//[appDelegate playClickSound];
	
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1)
	{
		athleteField.text = @"";
		eventField.text = @"";
        
        [nameArray removeAllObjects];
        [mainViewController updateFromSetupWithNames:[[nameArray copy] autorelease] andEvent:eventField.text];
        
        [nameTable reloadData];
	}
}

#pragma mark -
#pragma mark Athlete/Event Picker Methods

- (IBAction)openPicker:(id)sender
{	
	//[appDelegate playClickSound];
	
	pickView.hidden = NO;
	pickerToolbar.hidden = NO;
	pickerSeparatorImageView.hidden = NO;
    nameTable.hidden = YES;
    
	if (sender == pickAthleteButton)
    {
		currentEditField = athleteField;
        [self setPickerDataArrayWith:kAthletes];
    }
	else if (sender == pickEventButton)
	{
		currentEditField = eventField;
        [self setPickerDataArrayWith:kEvents];
	}

	pickAthleteButton.enabled = NO;
	pickEventButton.enabled = NO;
}

- (IBAction)pickerAdd
{
    [self pickerDoubleTap];
}

- (IBAction)pickerCancel
{	
	//[appDelegate playClickSound];
	
	pickAthleteButton.enabled = YES;
	pickEventButton.enabled = YES;
    pickView.hidden = YES;
    nameTable.hidden = NO;
    pickerToolbar.hidden = YES;
    pickerSeparatorImageView.hidden = YES;
}

- (void)pickerDoubleTap
{
    // get picker selection
    NSInteger row = [pickView selectedRowInComponent: 0];
    
    // set picker text in current edit field with current picker selection
    if (row < pickerDataArray.count)
        currentEditField.text = (NSString *)[pickerDataArray objectAtIndex:row];
    
    // if athlete picker, then add to the athlete name table
    if (currentEditField == athleteField && row < pickerDataArray.count)
    {
        [nameArray addObject:[pickerDataArray objectAtIndex:row]];
        [nameTable reloadData];
        
        athleteField.text = @"";
        [self scrollToLastLine];
    }
    
    // dismiss the picker and make sure picker buttons are enabled
    pickAthleteButton.enabled = YES;
    pickEventButton.enabled = YES;
    pickView.hidden = YES;
    nameTable.hidden = NO;
    pickerToolbar.hidden = YES;
    pickerSeparatorImageView.hidden = YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == tapGesture)
        return YES;
    
    return NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // no action
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [pickerDataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [pickerDataArray objectAtIndex:row];
}

- (void)setPickerDataArrayWith:(int)dataType
{
	[pickerDataArray removeAllObjects];
		
	char sql[250];
	sqlite3_stmt *statement;
	
	switch (dataType)
	{
		case kAthletes:	// RunnerName - populate with groups
			strcpy(sql, "SELECT DISTINCT RunnerName FROM Event ORDER BY RunnerName");
			break;
		case kEvents:	// EventName - populate with groups
			strcpy(sql, "SELECT DISTINCT EventName FROM Event ORDER BY EventName");
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
	
	// step through the result set rows (one per event)
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		NSString *rowText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		
		[pickerDataArray addObject:rowText];
	}
	
	sqlite3_finalize(statement);
	
	[pickView reloadAllComponents];
}

- (void)scrollToLastLine
{
    // scroll the last name into view
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(nameArray.count - 1) inSection:0];
        
    [nameTable scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IPAD) {
        return kiPadCellHeight;
    } else {
        return kiPhoneCellHeight;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [nameArray objectAtIndex:indexPath.row];
    if (IPAD) {
        cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:kiPadCellFontSize];
    } else {
        cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:kiPhoneCellFontSize];
    }
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // hilight the selected row
    //[nameTable selectRowAtIndexPath:indexPath
    //                       animated:YES
    //                 scrollPosition:UITableViewScrollPositionNone];
    
    // set text in current edit field with current nameTable selection
    //if (indexPath.row < [nameArray count])
    //    athleteField.text = (NSString *)[nameArray objectAtIndex:indexPath.row];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // remove object from tableItems and row from tableView
        [nameArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSUInteger fromRow = [fromIndexPath row];
    NSUInteger toRow = [toIndexPath row];
    
    id object = [[nameArray objectAtIndex:fromRow] retain];
    [nameArray removeObjectAtIndex:fromRow];
    [nameArray insertObject:object atIndex:toRow];
    [object release];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

@end
