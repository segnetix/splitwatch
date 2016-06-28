//
//  MultiStopwatchViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "MultiStopwatchViewController.h"
#import "MultiStopwatchSetupViewController.h"
#import "SettingsViewController.h"
#import "StopwatchAppDelegate.h"
#import "Stopwatch.h"
#import "Utilities.h"

#import "AboutViewController.h"

@implementation MultiStopwatchViewController

@synthesize runningTimeLabel;
@synthesize intervalDistanceLabel;
@synthesize startStopButton;
@synthesize clearResetButton;
@synthesize setupButton;
@synthesize settingsViewController;
@synthesize topSeparatorImageView;
@synthesize bottomSeparatorImageView;
@synthesize multiStopwatchTableViewController;
@synthesize appDelegate;
@synthesize bTimerRunning;
@synthesize iUnits;
@synthesize bKiloSplits;
@synthesize bFurlongMode;
@synthesize intervalDistance;
@synthesize timer;
@synthesize startTime;
@synthesize stopTime;
@synthesize elapsedTime;
@synthesize setupViewController;
@synthesize GREEN_COLOR;
@synthesize RED_COLOR;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
{
    if (self = [super init])
    {
        settingsViewController = theSettingsVC;
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.GREEN_COLOR = [UIColor colorWithRed:.2  green:.8 blue:.2 alpha: 1.0];
        self.RED_COLOR = [UIColor colorWithRed:1     green:0  blue:0  alpha: 1.0];
        
        // inital values
        bTimerRunning = NO;
        elapsedTime = 0;
        timer = nil;
        intervalDistance = 100;
        iUnits = kMetric;
        bKiloSplits = NO;
        bFurlongMode = NO;
        setupViewController = nil;
        
        // init interface elements
        startStopButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
        startStopButton.tag = @"startStopButton";
        
        clearResetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        clearResetButton.translatesAutoresizingMaskIntoConstraints = NO;
        clearResetButton.tag = @"clearResetButton";
        
        runningTimeLabel = [[UILabel alloc] init];
        runningTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        runningTimeLabel.tag = @"runningTimeLabel";
        
        intervalDistanceLabel = [[UILabel alloc] init];
        intervalDistanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        intervalDistanceLabel.tag = @"intervalDistanceLabel";
        
        setupButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        setupButton.translatesAutoresizingMaskIntoConstraints = NO;
        setupButton.tag = @"setupButton";
        
        UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
        topSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
        topSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
        bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // multiStopwatchTableViewController
        multiStopwatchTableViewController = [[MultiStopwatchTableViewController alloc]
                                             initWithIntervalDistance:[settingsViewController getLapInterval]
                                             eventType:[settingsViewController intervalUnits]
                                             kiloSplits:[settingsViewController isSetForKiloSplits]
                                             furlongMode:[settingsViewController isSetForFurlongDisplay]
                                             multiStopwatchViewController:self];
        multiStopwatchTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [runningTimeLabel release];
    [intervalDistanceLabel release];
    [startStopButton release];
    [clearResetButton release];
    [multiStopwatchTableViewController release];
    
    runningTimeLabel = nil;
    intervalDistanceLabel = nil;
    startStopButton = nil;
    clearResetButton = nil;
    multiStopwatchTableViewController = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // AutoLayout setup
    UIView* multiStopwatchView = multiStopwatchTableViewController.view;
    multiStopwatchView.tag = @"multiStopwatchView";
    
    NSDictionary *views = NSDictionaryOfVariableBindings(topSeparatorImageView, bottomSeparatorImageView, startStopButton, clearResetButton, setupButton, runningTimeLabel, intervalDistanceLabel, multiStopwatchView);

    [self.view addSubview:runningTimeLabel];
    runningTimeLabel.hidden = YES;
    
    // runningTime
    //runningTimeLabel.frame = CGRectMake(40, 20, 270, 40);
    if (IPAD) {
        runningTimeLabel.font = [UIFont fontWithName:FONT_NAME size:72];
    } else {
        runningTimeLabel.font = [UIFont fontWithName:FONT_NAME size:48];
    }
    runningTimeLabel.textAlignment = NSTextAlignmentRight;
    runningTimeLabel.textColor = [UIColor blackColor];
    runningTimeLabel.backgroundColor = [UIColor clearColor];
    if (elapsedTime > 0 || bTimerRunning) {
        [self updateTimeDisplays];
        runningTimeLabel.hidden = NO;
    } else {
        runningTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
        runningTimeLabel.hidden = YES;
    }
    [self.view addSubview:runningTimeLabel];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-180-[runningTimeLabel]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-36-[runningTimeLabel(86)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-90-[runningTimeLabel]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-26-[runningTimeLabel(64)]" options:0 metrics:nil views:views]];
    }
    [runningTimeLabel release];
    
    // intervalDistance label
    //intervalDistanceLabel.frame = CGRectMake(6, 12, 60, 26);
    if (IPAD) {
        intervalDistanceLabel.font = [UIFont fontWithName:FONT_NAME size:30];
    } else {
        intervalDistanceLabel.font = [UIFont fontWithName:FONT_NAME size:20];
    }
    intervalDistanceLabel.textColor = [UIColor blackColor];
    intervalDistanceLabel.backgroundColor = [UIColor clearColor];
    //intervalDistanceLabel.text = [Utilities shortFormatTime:0 precision:2];
    intervalDistanceLabel.textAlignment = NSTextAlignmentRight;
    if (!bTimerRunning)
        [self resetIntervalUnitsFromCurrentSettings];
    [self.view addSubview:intervalDistanceLabel];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-13-[intervalDistanceLabel(84)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-26-[intervalDistanceLabel(40)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-7-[intervalDistanceLabel(60)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-26-[intervalDistanceLabel(26)]" options:0 metrics:nil views:views]];
    }
    [intervalDistanceLabel release];
    
    // setupButton
    //setupButton.frame = CGRectMake(24, 58, 48, 28);
    [setupButton addTarget:self action:@selector(setupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [setupButton setTitle:@"Setup" forState:UIControlStateNormal];
    [setupButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [setupButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [setupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    setupButton.layer.borderColor = self.view.tintColor.CGColor;
    if (IPAD) {
        setupButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:20];
        setupButton.layer.borderWidth = 2.0f;
        setupButton.layer.cornerRadius = 14.0f;
    } else {
        setupButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:12];
        setupButton.layer.borderWidth = 1.0f;
        setupButton.layer.cornerRadius = 7.0f;
    }
    [self.view addSubview:setupButton];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[setupButton(80)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-73-[setupButton(48)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[setupButton(56)]" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[setupButton(32)]" options:0 metrics:nil views:views]];
    }
    
    // startStopButton
    //startStopButton.frame = CGRectMake(64, 48, 112, 53);
    //startStopButton.frame = CGRectMake(130, 8, 182, 64);
    [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    [startStopButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
    if (IPAD) {
        startStopButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:60];
        startStopButton.layer.borderWidth = 2.0f;
        startStopButton.layer.cornerRadius = 20.0f;
    } else {
        startStopButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40];
        startStopButton.layer.borderWidth = 1.0f;
        startStopButton.layer.cornerRadius = 12.0f;
    }
    [startStopButton addTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchDown];
    startStopButton.showsTouchWhenHighlighted = NO;
    [self.view addSubview:startStopButton];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-180-[startStopButton]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-34-[startStopButton(86)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-90-[startStopButton]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-28-[startStopButton(64)]" options:0 metrics:nil views:views]];
    }
    [startStopButton release];
    
    // clearResetButton [a clear (transparent) button to make the time display a button to reset the watch]
    [clearResetButton setBackgroundColor:[UIColor clearColor]];
    
    [clearResetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchDown];
    clearResetButton.showsTouchWhenHighlighted = NO;
    if (elapsedTime > 0 && !bTimerRunning) {
        clearResetButton.enabled = YES;
    } else {
        clearResetButton.enabled = NO;
    }
    [self.view addSubview:clearResetButton];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-180-[clearResetButton]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-34-[clearResetButton(86)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-90-[clearResetButton]-20-|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-26-[clearResetButton(64)]" options:0 metrics:nil views:views]];
    }
    [clearResetButton release];
    
    // separator between status bar and top panel
    [self.view addSubview:topSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topSeparatorImageView]|" options:0 metrics:nil views:views]];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[topSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[topSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    }
    [topSeparatorImageView release];
    
    // separator between top panel and the scrolling table view controller
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-131-[bottomSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-101-[bottomSeparatorImageView(1)]" options:0 metrics:nil views:views]];
    }
    [bottomSeparatorImageView release];
    
    // multi stopwatch view
    [self.view addSubview:multiStopwatchTableViewController.view];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[multiStopwatchView]|" options:0 metrics:nil views:views]];
    if (IPAD) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-132-[multiStopwatchView]-50-|" options:0 metrics:nil views:views]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-102-[multiStopwatchView]-50-|" options:0 metrics:nil views:views]];
    }
    
    // disable setup button if running
    if (elapsedTime > 0 || bTimerRunning) {
        appDelegate.multiStopwatchViewController.setupButton.enabled = NO;
        appDelegate.multiStopwatchViewController.setupButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    
    // can't change the interval units while the watch is running or splits displayed (must be in reset state]
    [self resetIntervalUnitsIfWatchIsReset];
    
    // but we can change button behavior from settings view at any time
    [self setWatchButtonBehavior];
    
    [super viewWillAppear:animated];
}

- (void)resetIntervalUnitsIfWatchIsReset
{
    // only reset from settings if the timer is in a reset state
    if (!bTimerRunning && [multiStopwatchTableViewController allWatchesReset])
    {
        [self resetIntervalUnitsFromCurrentSettings];
    }
}

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -

- (void)startTimerWithStartTime:(NSTimeInterval)time
{
    // START TIMER
    startTime = time;
    
    /*
     // for large time testing - will clip at 99:59:59.99
     //startTime -= 359695;
    */
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.03
                                             target: self
                                           selector: @selector(updateTimeDisplays)
                                           userInfo: nil
                                            repeats: YES];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    // update button states
    //[startStopButton setBackgroundImage:stopButtonImage forState:UIControlStateNormal];
}

- (void)startMainWatch
{
    // START TIMER
    bTimerRunning = YES;
    
    if (timer == nil)
    {
        [self startTimerWithStartTime:[NSDate timeIntervalSinceReferenceDate] - elapsedTime];
    }
    
    startStopButton.hidden = YES;
    runningTimeLabel.hidden = NO;
    clearResetButton.enabled = YES;
    
    // disable the info button
    appDelegate.multiStopwatchViewController.setupButton.enabled = NO;
    appDelegate.multiStopwatchViewController.setupButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)stopMainWatch
{
    // STOP TIMER
    bTimerRunning = NO;
    
    if (timer != nil)
    {
        stopTime = [NSDate timeIntervalSinceReferenceDate];
        elapsedTime = stopTime - startTime;
        
        [timer invalidate];
        timer = nil;
    }
    
    [self updateTimeDisplays];
    
    // update button state
    [startStopButton setEnabled:NO];
}

- (void)setupButtonPressed
{
    //[appDelegate playClickSound];
    
    setupViewController = [[MultiStopwatchSetupViewController alloc] initWithMainViewController:self];
    
    [self.navigationController pushViewController:setupViewController animated:YES];
    [setupViewController release];
}

- (void)startStopButtonPressed
{
    if ([multiStopwatchTableViewController.watches count] > 0)
    {
        // toggle state
        bTimerRunning = !bTimerRunning;
        
        if (bTimerRunning)
        {
            // START TIMER
            [self startMainWatch];
            [multiStopwatchTableViewController startAllWatches:startTime];
        }
        else
        {
            // STOP TIMER
            [self stopMainWatch];
            [multiStopwatchTableViewController stopAllWatches:stopTime];
        }
        
        // play click sound
        [appDelegate playClickSound];
        
        // disable the Setup button
        appDelegate.multiStopwatchViewController.setupButton.enabled = NO;
        appDelegate.multiStopwatchViewController.setupButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else
    {
        // alert that there are no watches set up
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No watches!"
                                                            message:@"Add watches via the Setup button before starting."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
}

- (void)resetButtonPressed
{
    if (bTimerRunning)
    {
        // do nothing if timer is running
    }
    else
    {
        // RESET BUTTON
        
        // play click sound
        [appDelegate playClickSound];
        
        // prompt for reset
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset all watches?"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void)setWatchButtonBehavior
{
    [startStopButton removeTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchDown];
    [startStopButton removeTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if ([settingsViewController isSetForTouchUpStart])
    {
        [startStopButton addTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [startStopButton addTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchDown];
    }
    
    // send start and lap button behavior to the cells
    [multiStopwatchTableViewController setWatchButtonBehavior];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        [self resetMultiwatch];
    }
    else
    {
        // do nothing
        //NSLog(@"cancel");
    }
}

- (void)addAllEventsToDatabase
{
    [multiStopwatchTableViewController addAllEventsToDatabase];
}

- (void)resetMultiwatch
{
    // OK button was pressed...
    
    [self resetMainClock];
    
    [multiStopwatchTableViewController resetAllWatches];
}

- (void)resetIntervalUnitsFromCurrentSettings
{
    intervalDistance = [settingsViewController getLapInterval];
    iUnits = [settingsViewController intervalUnits];
    bKiloSplits = [settingsViewController isSetForKiloSplits];
    bFurlongMode = [settingsViewController isSetForFurlongDisplay];
    
    // double check (in case settings get out of whack!)
    if (iUnits != kMetric || intervalDistance != 200)
        bKiloSplits = NO;
    
    if (iUnits != kEnglish || (intervalDistance != 220 || intervalDistance != 440))
        bFurlongMode = NO;
    
    [self resetIntervalUnitsFromStateData];
}

- (void)resetIntervalUnitsFromStateData
{
    [multiStopwatchTableViewController resetLapInterval:intervalDistance eventType:iUnits kiloSplits:bKiloSplits furlongMode:bFurlongMode];
    
    if (iUnits == kMetric)
        intervalDistanceLabel.text = [NSString stringWithFormat:@"%ldm", (long)intervalDistance];
    else if (iUnits == kEnglish && (intervalDistance == 220 || intervalDistance == 440) && [settingsViewController isSetForFurlongDisplay])
    {
        switch (intervalDistance)
        {
            case 220:	intervalDistanceLabel.text = @"1/8";	break;
            case 440:	intervalDistanceLabel.text = @"1/4";	break;
            default:	break;
        }
    }
    else if (iUnits == kEnglish)
        intervalDistanceLabel.text = [NSString stringWithFormat:@"%ldy", (long)intervalDistance];
    else if (iUnits == kLap)
        intervalDistanceLabel.text = @"Lap";
}

- (void)resetMainClock
{
    // hide running time
    runningTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
    runningTimeLabel.hidden = YES;
    
    // enable the start button
    [startStopButton setEnabled:YES];
    startStopButton.hidden = NO;
    clearResetButton.enabled = NO;
    
    elapsedTime = 0;
    
    [self resetIntervalUnitsFromCurrentSettings];
    
    // enable the setup button
    appDelegate.multiStopwatchViewController.setupButton.enabled = YES;
    appDelegate.multiStopwatchViewController.setupButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)updateTimeDisplays
{
    if (bTimerRunning)
    {
        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval currentRunningTime = nowTime - startTime;
        
        runningTimeLabel.text = [Utilities shortFormatTime:currentRunningTime precision:2];
    }
    else
    {
        runningTimeLabel.text = [Utilities shortFormatTime:elapsedTime precision:2];
    }
}

- (void)updateFromSetupWithNames:(NSMutableArray *)nameArray andEvent:(NSString *)event
{
    if (!bTimerRunning)
    {
        [multiStopwatchTableViewController setupWatchesWithRunnerNames:nameArray EventName:event];
    }
}

- (NSArray *)getNames
{
    NSMutableArray *names = [[[NSMutableArray alloc] initWithCapacity:12] autorelease];
    
    for (Stopwatch *watch in multiStopwatchTableViewController.watches)
    {
        [names addObject:watch.runnerName];
    }
    
    return names;
}

- (NSString *)getEventName
{
    for (Stopwatch *watch in multiStopwatchTableViewController.watches)
    {
        if (watch.eventName.length > 0)
            return watch.eventName;
    }
    
    return @"";
}

- (void)saveStateToFile:(NSString *)rootFilePath
{
    // save multi stopwatch state
    NSArray *keys = [NSArray arrayWithObjects:
                     @"MultiStopwatchStartTime",
                     @"MultiStopwatchStopTime",
                     @"MultiStopwatchElapsedTime",
                     @"MultiStopwatchData",
                     @"MultiStopwatchIntervalDistance",
                     @"MultiStopwatchUnits",
                     @"MultiStopwatchKiloSplits",
                     @"MultiStopwatchFurlongMode",
                     //@"MultiStopwatchEventName",
                     nil];
    
    NSTimeInterval tempStartTime = 0;
    
    if (self.bTimerRunning)
    {
        tempStartTime = self.startTime;
    }
    
    // main stopwatch display state
    NSNumber *stopwatchStartTime = [NSNumber numberWithDouble:tempStartTime];
    NSNumber *stopwatchStopTime = [NSNumber numberWithDouble:self.stopTime];
    NSNumber *stopwatchElapsedTime = [NSNumber numberWithDouble:self.elapsedTime];
    NSNumber *stopwatchIntervalDistance = [NSNumber numberWithInt:(int)self.intervalDistance];
    NSNumber *stopwatchUnits = [NSNumber numberWithInt:self.iUnits];
    NSNumber *stopwatchKiloUnits = [NSNumber numberWithInt:(self.bKiloSplits ? 1 : 0)];
    NSNumber *stopwatchFurlongMode = [NSNumber numberWithInt:(self.bFurlongMode ? 1 : 0)];
    
    // individual watch data
    NSMutableArray *watchDataArray = [multiStopwatchTableViewController getWatchStateData];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        stopwatchStartTime,
                        stopwatchStopTime,
                        stopwatchElapsedTime,
                        watchDataArray,
                        stopwatchIntervalDistance,
                        stopwatchUnits,
                        stopwatchKiloUnits,
                        stopwatchFurlongMode,
                        nil];
    
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"MultiStopwatchStateData.plist"];
    
    [dataDictionary writeToFile:filePath atomically:YES];
    [dataDictionary release];
}

- (void)loadStateFromFile:(NSString *)rootFilePath
{
    NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"MultiStopwatchStateData.plist"];
    
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    if (dataDictionary.count > 0)
    {
        NSNumber *stopwatchStartTime = [dataDictionary objectForKey:@"MultiStopwatchStartTime"];
        NSNumber *stopwatchStopTime = [dataDictionary objectForKey:@"MultiStopwatchStopTime"];
        NSNumber *stopwatchElapsedTime = [dataDictionary objectForKey:@"MultiStopwatchElapsedTime"];
        NSNumber *stopwatchIntervalDistance = [dataDictionary objectForKey:@"MultiStopwatchIntervalDistance"];
        NSNumber *stopwatchUnits = [dataDictionary objectForKey:@"MultiStopwatchUnits"];
        NSNumber *stopwatchKiloUnits = [dataDictionary objectForKey:@"MultiStopwatchKiloSplits"];
        NSNumber *stopwatchFurlongMode = [dataDictionary objectForKey:@"MultiStopwatchFurlongMode"];
        NSArray  *watchDataArray = [dataDictionary objectForKey:@"MultiStopwatchData"];
        //NSString *stopwatchEventName = [dataDictionary objectForKey:@"MultiStopwatchEventName"];
        
        self.stopTime = [stopwatchStopTime doubleValue];
        self.elapsedTime = [stopwatchElapsedTime doubleValue];
        self.startTime = [stopwatchStartTime doubleValue];
        
        bTimerRunning = ([stopwatchStartTime doubleValue] > 0);
        
        intervalDistance = [stopwatchIntervalDistance intValue];
        iUnits = [stopwatchUnits intValue];
        bKiloSplits = ([stopwatchKiloUnits intValue] == 1) ? 1 : 0;
        bFurlongMode = ([stopwatchFurlongMode intValue] == 1) ? 1 : 0;
        [self resetIntervalUnitsFromStateData];
        
        if (bTimerRunning)
        {
            [self startTimerWithStartTime:startTime];
        }
        
        // set main display as necessary
        if (bTimerRunning || elapsedTime > 0)
        {
            startStopButton.hidden = YES;
            runningTimeLabel.hidden = NO;
            clearResetButton.enabled = YES;
            
            //[self updateTimeDisplays];
        }
        
        // set the multi watches
        [multiStopwatchTableViewController setWatchStateData:watchDataArray];
        
        [self updateTimeDisplays];
    }
    
    [dataDictionary release];
}

@end

