//
//  StopwatchViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "StopwatchViewController.h"
#import "StopwatchAppDelegate.h"
#import "Utilities.h"
#import "Event.h"
#import <QuartzCore/QuartzCore.h>

@implementation StopwatchViewController

//@synthesize stopButtonImage;
//@synthesize startButtonImage;
//@synthesize lapButtonImage;
//@synthesize resetButtonImage;
@synthesize backgroundView;
@synthesize runningTimeLabel;
@synthesize lapTimeLabel;
@synthesize lapCountLabel;
@synthesize intervalDistanceLabel;
@synthesize splitViewHeader;
@synthesize startStopButton;
@synthesize lapResetButton;
@synthesize clearToggleButton;
@synthesize splitDetailViewController;
@synthesize settingsViewController;
@synthesize bTimerRunning;
@synthesize iUnits;
@synthesize bKiloSplits;
@synthesize bFurlongMode;
@synthesize lapCount;
@synthesize intervalDistance;
@synthesize timer;
@synthesize startTime;
@synthesize stopTime;
@synthesize lapTime;
@synthesize elapsedTime;
@synthesize previousLapTime;
@synthesize appDelegate;
@synthesize bLapFreeze;
@synthesize bFlipTimeDisplay;
@synthesize lapFreezeTimer;
@synthesize GREEN_COLOR;
@synthesize RED_COLOR;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
{
    if (self = [super init])
    {
        // for access to settings
        settingsViewController = theSettingsVC;
        
        // for access to SQL functions
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // init interface elements
        backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundView.tag = @"backgroundView";
        
        runningTimeLabel = [[UILabel alloc] init];
        runningTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        runningTimeLabel.tag = @"runningTimeLabel";
        
        lapTimeLabel = [[UILabel alloc] init];
        lapTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        lapTimeLabel.tag = @"lapTimeLabel";
        
        lapCountLabel = [[UILabel alloc] init];
        lapCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        lapCountLabel.tag = @"lapCountLabel";
        
        intervalDistanceLabel = [[UILabel alloc] init];
        intervalDistanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        intervalDistanceLabel.tag = @"intervalDistanceLabel";
        
        splitViewHeader = [[UILabel alloc] init];
        splitViewHeader.translatesAutoresizingMaskIntoConstraints = NO;
        splitViewHeader.tag = @"splitViewHeader";
        
        startStopButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
        startStopButton.tag = @"startStopButton";
        
        lapResetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        lapResetButton.translatesAutoresizingMaskIntoConstraints = NO;
        lapResetButton.tag = @"lapResetButton";
        
        clearToggleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        clearToggleButton.translatesAutoresizingMaskIntoConstraints = NO;
        clearToggleButton.tag = @"clearToggleButton";
        
        splitDetailViewController = [[SplitDetailViewController alloc]
                                     initWithIntervalDistance:[settingsViewController getLapInterval]
                                     Units:[settingsViewController intervalUnits]
                                     KiloSplits:[settingsViewController isSetForKiloSplits]
                                     FurlongMode:[settingsViewController isSetForFurlongDisplay]
                                     Finished:NO
                                     EditMode:NO];
        splitDetailViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        splitDetailViewController.tableView.scrollEnabled = YES;
        splitDetailViewController.tableView.bounces = YES;
        
        // inital values
        intervalDistance = 100;
        iUnits = kMetric;
        bKiloSplits = NO;
        bFurlongMode = NO;
        bTimerRunning = NO;
        lapFreezeTimer = nil;
        bLapFreeze = NO;
        bFlipTimeDisplay = NO;
        
        self.GREEN_COLOR = [UIColor colorWithRed:.2  green:.8 blue:.2 alpha: 1.0];
        self.RED_COLOR = [UIColor colorWithRed:1     green:0  blue:0  alpha: 1.0];
    }
    
    return self;
}

- (void)dealloc
{
    [backgroundView release];
    [GREEN_COLOR release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // AutoLayout setup
    UIView* splitDetailView = splitDetailViewController.view;
    splitDetailView.tag = @"splitDetailView";
    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundView, runningTimeLabel, clearToggleButton, lapTimeLabel, lapCountLabel, intervalDistanceLabel, startStopButton, lapResetButton, splitViewHeader, splitDetailView);
    
    // backgroundImageView
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[backgroundView(150)]" options:0 metrics:nil views:views]];
    [backgroundView release];
    
    // runningTime
    runningTimeLabel.font = [UIFont fontWithName:FONT_NAME size:48];
    runningTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
    runningTimeLabel.textAlignment = NSTextAlignmentRight;
    runningTimeLabel.textColor = [UIColor blackColor];
    runningTimeLabel.backgroundColor = [UIColor clearColor];
    runningTimeLabel.userInteractionEnabled = YES;
    [self.view addSubview:runningTimeLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[runningTimeLabel]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[runningTimeLabel(52)]" options:0 metrics:nil views:views]];
    [runningTimeLabel release];
    
    // clear toggle button [a clear (transparent) button to make the time display a button to toggle main with the lap display]
    [clearToggleButton setBackgroundColor:[UIColor clearColor]];
    [clearToggleButton addTarget:self action:@selector(toggleButtonPressed) forControlEvents:UIControlEventTouchDown];
    clearToggleButton.showsTouchWhenHighlighted = NO;
    [self.view addSubview:clearToggleButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[clearToggleButton]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[clearToggleButton(52)]" options:0 metrics:nil views:views]];
    [clearToggleButton release];
    
    // lapTime
    lapTimeLabel.font = [UIFont fontWithName:FONT_NAME size:20];
    lapTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
    lapTimeLabel.textAlignment = NSTextAlignmentRight;
    lapTimeLabel.textColor = [UIColor blackColor];
    lapTimeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lapTimeLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lapTimeLabel(115)]-5-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[lapTimeLabel(26)]" options:0 metrics:nil views:views]];
    [lapTimeLabel release];
    
    // lapCount
    lapCountLabel.font = [UIFont fontWithName:FONT_NAME size:20];
    lapCountLabel.text = [Utilities formatLap:0];
    lapCountLabel.textAlignment = NSTextAlignmentCenter;
    lapCountLabel.textColor = [UIColor blackColor];
    lapCountLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lapCountLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lapCountLabel(52)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[lapCountLabel(26)]" options:0 metrics:nil views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lapCountLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    [lapCountLabel release];
    
    // intervalDistanceLabel
    intervalDistanceLabel.font = [UIFont fontWithName:FONT_NAME size:20];
    intervalDistanceLabel.textColor = [UIColor blackColor];
    intervalDistanceLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:intervalDistanceLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[intervalDistanceLabel(80)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-18-[intervalDistanceLabel(26)]" options:0 metrics:nil views:views]];
    [intervalDistanceLabel release];
    
    // startStopButton
    if (bTimerRunning)
    {
        [startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
        startStopButton.layer.borderColor = RED_COLOR.CGColor;
    }
    else
    {
        [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
        startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
    }
    
    [startStopButton addTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchDown];
    [startStopButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [startStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    startStopButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40];
    startStopButton.layer.borderWidth = 1.0f;
    startStopButton.layer.cornerRadius = 12.0f;
    startStopButton.showsTouchWhenHighlighted = NO;
    
    [self.view addSubview:startStopButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[startStopButton(132)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-90-[startStopButton(50)]" options:0 metrics:nil views:views]];
    [startStopButton release];
    
    // lapResetButton
    [lapResetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lapResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [lapResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [lapResetButton setTitle:@"Lap" forState:UIControlStateNormal];
    lapResetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40];
    lapResetButton.layer.borderWidth = 1.0f;
    lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
    lapResetButton.layer.cornerRadius = 12.0f;
    [lapResetButton addTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchDown];
    lapResetButton.showsTouchWhenHighlighted = NO;
    [self.view addSubview:lapResetButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lapResetButton(132)]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-90-[lapResetButton(50)]" options:0 metrics:nil views:views]];
    [lapResetButton release];
    
    // splitViewHeader
    splitViewHeader.font = [UIFont fontWithName:FONT_NAME size:15];
    splitViewHeader.textColor = [UIColor blackColor];
    splitViewHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    splitViewHeader.text = [Utilities getSplitViewHeaderText:[settingsViewController getLapInterval]
                                                       Units:[settingsViewController intervalUnits]
                                                  KiloSplits:[settingsViewController isSetForKiloSplits]
                                          FurlongDisplayMode:[settingsViewController isSetForFurlongDisplay]];
    [self.view addSubview:splitViewHeader];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitViewHeader]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[splitViewHeader(20)]" options:0 metrics:nil views:views]];
    [splitViewHeader release];
    
    // splitDetailViewController
    [self.view addSubview:splitDetailView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitDetailView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-170-[splitDetailView]-50-|" options:0 metrics:nil views:views]];
    
    bTimerRunning = (startTime > 0);
    
    [self updateButtonState];
}

- (void)viewWillAppear:(BOOL)animated
{
    // can't change the interval units while the watch is running or splits displayed
    if (!bTimerRunning && splitDetailViewController.splits.count == 0)
    {
        [self resetIntervalUnitsFromCurrentSettings];
    }
    
    // but we can change the start and lap button behaviors
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
    
    [lapResetButton removeTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchDown];
    [lapResetButton removeTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if ([settingsViewController isSetForTouchUpLap])
    {
        [lapResetButton addTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [lapResetButton addTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchDown];
    }
    
    [super viewWillAppear:animated];
}

- (void)startTimerWithStartTime:(NSTimeInterval)time
{
    // START TIMER
    startTime = time;
    lapTime = startTime;
    previousLapTime = lapTime;
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.035
                                             target: self
                                           selector: @selector(updateTimeDisplays)
                                           userInfo: nil
                                            repeats: YES];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // update button states
    //[startStopButton setBackgroundImage:stopButtonImage forState:UIControlStateNormal];
    [startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
    startStopButton.layer.borderColor = RED_COLOR.CGColor;
    
    // lock manual split view scrolling (?)
    // v2.0 - left scrolling enabled at all times
    splitDetailViewController.tableView.scrollEnabled = YES;
    splitDetailViewController.tableView.bounces = NO;
}

- (void)stopTimer
{
    // STOP TIMER
    stopTime = [NSDate timeIntervalSinceReferenceDate];
    [timer invalidate];
    timer = nil;
    
    elapsedTime = stopTime - startTime;
    previousLapTime = lapTime;
    lapTime = stopTime;
    lapCount++;
    
    [self updateButtonState];
    
    [appDelegate playClickSound];
    
    // delay the post run tasks to give all labels
    // a chance to complete their refresh
    [NSTimer scheduledTimerWithTimeInterval: 0.2
                                     target: self
                                   selector: @selector(cleanUpOnStop)
                                   userInfo: nil
                                    repeats: NO];
}

- (void)startStopButtonPressed
{
    // toggle state
    bTimerRunning = !bTimerRunning;
    bLapFreeze = NO;
    
    // call appropriate method
    if (bTimerRunning)
    {
        // START BUTTON
        [self startTimerWithStartTime:[NSDate timeIntervalSinceReferenceDate] - elapsedTime];
    }
    else
    {
        // STOP BUTTON
        [self stopTimer];
    }
    
    [self flashBackground];
    [appDelegate playClickSound];
}

- (void)lapResetButtonPressed
{
    // play click sound
    [appDelegate playClickSound];
    
    if (bTimerRunning)
    {
        // LAP BUTTON
        previousLapTime = lapTime;
        lapTime = [NSDate timeIntervalSinceReferenceDate];
        lapCount++;
        
        // lap tasks (with delay)
        [self flashBackground];			// 0.08
        [self disableLapButton];		// 2.0
        [self freezeLapDisplay];		// 5.0
        [self addSplitWithDelay];		// 0.15
    }
    else
    {
        UILabel *mainTimeDisplay = runningTimeLabel;
        UILabel *secondaryTimeDisplay = lapTimeLabel;
        
        if (bFlipTimeDisplay)
        {
            mainTimeDisplay = lapTimeLabel;
            secondaryTimeDisplay = runningTimeLabel;
        }
        
        // RESET BUTTON
        mainTimeDisplay.text = [Utilities shortFormatTime:0 precision:2];
        secondaryTimeDisplay.text = [Utilities shortFormatTime:0 precision:2];
        lapCountLabel.text = [Utilities formatLap:0];
        [splitDetailViewController clearSplits];
        
        // enable the start button
        //[startStopButton setBackgroundImage:startButtonImage forState:UIControlStateNormal];
        [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
        startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
        [startStopButton setEnabled:YES];
        
        // set the lap button state
        //[lapResetButton setBackgroundImage:lapButtonImage forState:UIControlStateNormal];
        [lapResetButton setTitle:@"Lap" forState:UIControlStateNormal];
        
        lapCount = 0;
        lapTime = 0;
        elapsedTime = 0;
        previousLapTime = 0;
        
        [self resetIntervalUnitsFromCurrentSettings];
        splitDetailViewController.bFinished = NO;
    }
}

- (void)toggleButtonPressed
{
    //[appDelegate playClickSound];
    
    bFlipTimeDisplay = !bFlipTimeDisplay;
    
    if (!bTimerRunning)
    {
        [self updateTimeDisplays];
    }
}

- (void)resetIntervalUnitsFromCurrentSettings
{
    intervalDistance = [settingsViewController getLapInterval];
    iUnits = [settingsViewController intervalUnits];
    bKiloSplits = [settingsViewController isSetForKiloSplits];
    bFurlongMode = [settingsViewController isSetForFurlongDisplay];
    
    // double check (in case settings get out of whack!)
    if (iUnits != kMetric || intervalDistance != 200)
    {
        bKiloSplits = NO;
    }
    
    if (iUnits != kEnglish || (intervalDistance != 220 && intervalDistance != 440))
    {
        bFurlongMode = NO;
    }
    
    [self resetIntervalUnitsFromStateData];
}

- (void)resetIntervalUnitsFromStateData
{
    [splitDetailViewController resetLapInterval:intervalDistance Units:iUnits KiloSplits:bKiloSplits FurlongMode:bFurlongMode];
    splitViewHeader.text = [Utilities getSplitViewHeaderText:intervalDistance Units:iUnits KiloSplits:bKiloSplits FurlongDisplayMode:bFurlongMode];
    
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

- (void)updateTimeDisplays
{
    UILabel *mainTimeDisplay = runningTimeLabel;
    UILabel *secondaryTimeDisplay = lapTimeLabel;
    
    if (bFlipTimeDisplay)
    {
        mainTimeDisplay = lapTimeLabel;
        secondaryTimeDisplay = runningTimeLabel;
    }
    
    if (bTimerRunning)
    {
        NSTimeInterval nowTime = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval currentRunningTime = nowTime - startTime;
        NSTimeInterval currentLapTime = nowTime - lapTime;
        
        mainTimeDisplay.text = [Utilities shortFormatTime:currentRunningTime precision:2];
        
        if (bLapFreeze)
        {
            secondaryTimeDisplay.text = [Utilities shortFormatTime:(lapTime - previousLapTime) precision:2];
        }
        else
        {
            secondaryTimeDisplay.text = [Utilities shortFormatTime:currentLapTime precision:2];
        }
        
        lapCountLabel.text = [Utilities formatLap:lapCount];
    }
    else
    {
        mainTimeDisplay.text = [Utilities shortFormatTime:elapsedTime precision:2];
        secondaryTimeDisplay.text = [Utilities shortFormatTime:(lapTime - previousLapTime) precision:2];
        lapCountLabel.text = [Utilities formatLap:lapCount];
    }
}

- (void)updateButtonState
{
    // update button state
    if (bTimerRunning)
    {
        [startStopButton setEnabled:YES];
        [startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
        startStopButton.layer.borderColor = RED_COLOR.CGColor;
        [lapResetButton setTitle:@"Lap" forState:UIControlStateNormal];
    }
    else
    {
        if (lapCount > 0)
        {
            [startStopButton setEnabled:NO];
            [startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
            [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
            startStopButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            [lapResetButton setEnabled:YES];
            [lapResetButton setTitle:@"Reset" forState:UIControlStateNormal];
        }
        else
        {
            [startStopButton setEnabled:YES];
            [startStopButton setTitle:@"Start" forState:UIControlStateNormal];
            [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
            startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
            [lapResetButton setTitle:@"Lap" forState:UIControlStateNormal];
        }
        
        [lapResetButton setEnabled:YES];
        lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self updateTimeDisplays];
    }
}

- (NSArray *)getSplits
{
    return [splitDetailViewController getSplits];
}

- (void)setSplitData:(NSArray *)splitData
{
    for (NSNumber *num in splitData)
    {
        [splitDetailViewController addSplit:[num doubleValue]];
    }
}

- (void)saveStateToFile:(NSString *)rootFilePath
{
    // save main stopwatch state
    NSArray *keys = [NSArray arrayWithObjects:
                     @"StopwatchStartTime",
                     @"StopwatchStopTime",
                     @"StopwatchElapsedTime",
                     @"StopwatchLapTime",
                     @"StopwatchPreviousLapTime",
                     @"StopwatchLapCount",
                     @"StopwatchSplits",
                     @"StopwatchIntervalDistance",
                     @"StopwatchUnits",
                     @"StopwatchKiloSplits",
                     @"StopwatchFurlongMode",
                     nil];
    
    NSTimeInterval tempStartTime = self.startTime;
    
    if (!self.bTimerRunning)
    {
        tempStartTime = 0;
    }
    
    NSNumber *stopwatchStartTime = [NSNumber numberWithDouble:tempStartTime];
    NSNumber *stopwatchStopTime = [NSNumber numberWithDouble:self.stopTime];
    NSNumber *stopwatchElapsedTime = [NSNumber numberWithDouble:self.elapsedTime];
    NSNumber *stopwatchLapTime = [NSNumber numberWithDouble:self.lapTime];
    NSNumber *stopwatchPreviousLapTime = [NSNumber numberWithDouble:self.previousLapTime];
    NSNumber *stopwatchLapCount = [NSNumber numberWithInt:(int)self.lapCount];
    NSNumber *stopwatchIntervalDistance = [NSNumber numberWithInt:(int)self.intervalDistance];
    NSNumber *stopwatchUnits = [NSNumber numberWithInt:iUnits];
    NSNumber *stopwatchKiloUnits = [NSNumber numberWithInt:(bKiloSplits ? 1 : 0)];
    NSNumber *stopwatchFurlongMode = [NSNumber numberWithInt:(bFurlongMode ? 1 : 0)];
    NSArray *stopwatchSplits = [self getSplits];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        stopwatchStartTime,
                        stopwatchStopTime,
                        stopwatchElapsedTime,
                        stopwatchLapTime,
                        stopwatchPreviousLapTime,
                        stopwatchLapCount,
                        stopwatchSplits,
                        stopwatchIntervalDistance,
                        stopwatchUnits,
                        stopwatchKiloUnits,
                        stopwatchFurlongMode,
                        nil];
    
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"StopwatchStateData.plist"];
    
    [dataDictionary writeToFile:filePath atomically:YES];
    [dataDictionary release];
}

- (void)loadStateFromFile:(NSString *)rootFilePath
{
    NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"StopwatchStateData.plist"];
    
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    if (dataDictionary.count > 0)
    {
        NSNumber *stopwatchStartTime = [dataDictionary objectForKey:@"StopwatchStartTime"];
        NSNumber *stopwatchStopTime = [dataDictionary objectForKey:@"StopwatchStopTime"];
        NSNumber *stopwatchElapsedTime = [dataDictionary objectForKey:@"StopwatchElapsedTime"];
        NSNumber *stopwatchLapTime = [dataDictionary objectForKey:@"StopwatchLapTime"];
        NSNumber *stopwatchPreviousLapTime = [dataDictionary objectForKey:@"StopwatchPreviousLapTime"];
        NSNumber *stopwatchLapCount = [dataDictionary objectForKey:@"StopwatchLapCount"];
        NSNumber *stopwatchIntervalDistance = [dataDictionary objectForKey:@"StopwatchIntervalDistance"];
        NSNumber *stopwatchUnits = [dataDictionary objectForKey:@"StopwatchUnits"];
        NSNumber *stopwatchKiloUnits = [dataDictionary objectForKey:@"StopwatchKiloSplits"];
        NSNumber *stopwatchFurlongMode = [dataDictionary objectForKey:@"StopwatchFurlongMode"];
        NSArray *stopwatchSplits = [dataDictionary objectForKey:@"StopwatchSplits"];
        
        bTimerRunning = ([stopwatchStartTime doubleValue] > 0);
        
        intervalDistance = [stopwatchIntervalDistance intValue];
        iUnits = [stopwatchUnits intValue];
        bKiloSplits = ([stopwatchKiloUnits intValue] == 1) ? 1 : 0;
        bFurlongMode = ([stopwatchFurlongMode intValue] == 1) ? 1 : 0;
        [self resetIntervalUnitsFromStateData];
        
        if (bTimerRunning)
        {
            [self startTimerWithStartTime:[stopwatchStartTime doubleValue]];
        }
        
        if (stopwatchLapCount > 0)
        {
            startTime = [stopwatchStartTime doubleValue];
            stopTime = [stopwatchStopTime doubleValue];
            elapsedTime = [stopwatchElapsedTime doubleValue];
            lapTime = [stopwatchLapTime doubleValue];
            previousLapTime = [stopwatchPreviousLapTime doubleValue];
            lapCount = [stopwatchLapCount intValue];
            [self setSplitData:stopwatchSplits];
        }
        
        [self updateButtonState];
    }
    
    [dataDictionary release];
}

- (void)cleanUpOnStop
{
    // add last split to split window
    [splitDetailViewController addSplit:elapsedTime];
    //[splitDetailViewController addLastSplitRows];
    
    // create new event - it will add itself to the event database
    Event *event = [[Event alloc] initWithRunnerName:@""
                                           EventName:@""
                                       EventDateTime:[NSDate timeIntervalSinceReferenceDate] - [splitDetailViewController getFinalTime]
                                       EventDistance:[splitDetailViewController getFinalDistance]
                                      EventFinalTime:[splitDetailViewController getFinalTime]
                                    EventLapDistance:self.intervalDistance
                                      EventSplitData:[splitDetailViewController getSplits]
                                           EventType:iUnits
                                          KiloSplits:bKiloSplits
                                         FurlongMode:bFurlongMode];
    
    [event release];
    
    splitDetailViewController.tableView.bounces = YES;
    
    /*
    // enable manual split view scrolling if we have more splits than can be held at one time
    if (lapCount > 6)
    {
        splitDetailViewController.tableView.scrollEnabled = YES;
    }
    */
    
    splitDetailViewController.bFinished = YES;
    
    [splitDetailViewController.tableView reloadData];
    
    [splitDetailViewController scrollToLastLine];
}

// if watch is running then temporarily disable the lap button (2 sec) to prevent an inadvertent double-hit
- (void)disableLapButton
{
    if ([settingsViewController isSetForLapDelay])
    {
        lapResetButton.enabled = NO;
        lapResetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        NSTimer *enableLapButtonTimer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                                         target: self
                                                                       selector: @selector(enableLapButton)
                                                                       userInfo: nil
                                                                        repeats: NO];
        
        // this will allow the timer to fire on any loop in case the user is scrolling
        [[NSRunLoop currentRunLoop] addTimer:enableLapButtonTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)enableLapButton
{
    lapResetButton.enabled = YES;
    lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)flashBackground
{
     // flash the background
     //splitViewHeader.backgroundColor = [UIColor lightGrayColor];
     backgroundView.backgroundColor = [UIColor darkGrayColor];
    
     // set timer for unflash
     NSTimer *unflashBackgroundTimer = [NSTimer scheduledTimerWithTimeInterval: 0.08
                                              target: self
                                            selector: @selector(unflashBackground)
                                            userInfo: nil
                                             repeats: NO];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:unflashBackgroundTimer forMode:NSRunLoopCommonModes];
}

- (void)unflashBackground
{	
    // unflash the background
    //backgroundImageView.image = backgroundGradientImage;
    //splitViewHeader.backgroundColor = [UIColor blackColor];
    backgroundView.backgroundColor = [UIColor whiteColor];
}

- (void)freezeLapDisplay
{
    bLapFreeze = YES;
    
    if (lapFreezeTimer != nil)
    {
        [lapFreezeTimer invalidate];
        lapFreezeTimer = nil;
    }
    
    lapFreezeTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                      target: self
                                                    selector: @selector(unfreezeLapDisplay)
                                                    userInfo: nil
                                                     repeats: NO];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:lapFreezeTimer forMode:NSRunLoopCommonModes];
}

- (void)unfreezeLapDisplay
{
    bLapFreeze = NO;
    lapFreezeTimer = nil;
}

- (void)addSplit
{
    // add a split to split table
    [splitDetailViewController addSplit:lapTime - startTime];
}

- (void)addSplitWithDelay
{
    [NSTimer scheduledTimerWithTimeInterval: 0.15
                                     target: self
                                   selector: @selector(addSplit)
                                   userInfo: nil
                                    repeats: NO];
}

@end