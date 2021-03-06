//
//  MultiwatchCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 7/7/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "MultiwatchCell.h"
#import "StopwatchAppDelegate.h"
#import "Utilities.h"
#import "Event.h"

@implementation MultiwatchCell

@synthesize backgroundView;
@synthesize startStopButton;
@synthesize lapResetButton;
@synthesize runnersNameLabel;
@synthesize runningTimeLabel;
@synthesize lapTimeLabel;
@synthesize completedDistanceLabel;
@synthesize completedDistanceTime;
@synthesize watch;
@synthesize lastLapButtonPressTime;
@synthesize appDelegate;
@synthesize lapFreezeTimer;
@synthesize bLapFreeze;
@synthesize GREEN_COLOR;
@synthesize RED_COLOR;

- (void)initialize
{
    appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.GREEN_COLOR = [UIColor colorWithRed:.2  green:.8 blue:.2 alpha: 1.0];
    self.RED_COLOR = [UIColor colorWithRed:1     green:0  blue:0  alpha: 1.0];
    
    lapTimeLabel.text = @"";
    runningTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
    //lapCountLabel.text = [Utilities formatLap:0];
    completedDistanceLabel.text = @"";
    completedDistanceTime.text = @"";
    
    // startStop button
    [startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    [startStopButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [startStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
    if (IPAD) {
        startStopButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:32];
        startStopButton.layer.borderWidth = 2.0f;
        startStopButton.layer.cornerRadius = 20.0f;
    } else {
        startStopButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:20];
        startStopButton.layer.borderWidth = 1.0f;
        startStopButton.layer.cornerRadius = 12.0f;
    }
    startStopButton.showsTouchWhenHighlighted = NO;
    [startStopButton addTarget:self action:@selector(startStopButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    // lapReset button
    [lapResetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lapResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [lapResetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [lapResetButton setTitle:NSLocalizedString(@"Lap", nil) forState:UIControlStateNormal];
    if (IPAD) {
        lapResetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:32];
        lapResetButton.layer.borderWidth = 2.0f;
        lapResetButton.layer.cornerRadius = 20.0f;
    } else {
        lapResetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:20];
        lapResetButton.layer.borderWidth = 1.0f;
        lapResetButton.layer.cornerRadius = 12.0f;
    }
    lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
    [lapResetButton addTarget:self action:@selector(lapResetButtonPressed) forControlEvents:UIControlEventTouchDown];
    lapResetButton.showsTouchWhenHighlighted = NO;
    
    //[self addObserver:self forKeyPath:@"lapCountLabel.frame" options:NSKeyValueObservingOptionNew context:nil];
    
}

/*
 - (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
 if ([keyPath isEqual:@"lapCountLabel.frame"]) {
 NSLog(@"lapCountLabel.frame is %@", NSStringFromCGRect(lapCountLabel.frame));
 }
 }
 */

- (void)additionalSetup
{
    lastLapButtonPressTime = 0;
    lapFreezeTimer = nil;
    bLapFreeze = NO;
    
    // update the lapCountLabel
    int intervalDistance = (int)appDelegate.multiStopwatchViewController.intervalDistance;
    int iEventType = (int)appDelegate.multiStopwatchViewController.iUnits;
    BOOL bFurlongMode = appDelegate.multiStopwatchViewController.bFurlongMode;
    
    // v2.2 change - show completed distance instead of lap count
    if (watch.lapCount > 0) {
        completedDistanceLabel.text = [Utilities stringFromDistance:watch.lapCount*intervalDistance Units:iEventType ShowSplitTag:NO Interval:intervalDistance FurlongDisplayMode:bFurlongMode];
        completedDistanceTime.text = [Utilities timeTextForRow:watch.splits.count-1 forDisplayMode:kDisplayMode_Normal forSplits:watch.splits forIntervalDistance:intervalDistance forUnits:intervalDistance forFurlongMode:bFurlongMode];
    } else {
        completedDistanceLabel.text = @"";
        completedDistanceTime.text = @"";
    }
    
    [self updateTimeDisplays];
    [self updateButtonState];
    [self setWatchButtonBehavior];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [startStopButton release];
    [lapResetButton release];
    [runnersNameLabel release];
    [runningTimeLabel release];
    [lapTimeLabel release];
    [completedDistanceLabel release];
    [completedDistanceTime release];
    [backgroundView release];
    
    [RED_COLOR release];
    [GREEN_COLOR release];
    [lapFreezeTimer release];
    [watch release];
    
    startStopButton = nil;
    lapResetButton = nil;
    runnersNameLabel = nil;
    runningTimeLabel = nil;
    lapTimeLabel = nil;
    completedDistanceLabel = nil;
    completedDistanceTime = nil;
    backgroundView = nil;
    lapFreezeTimer = nil;
    watch = nil;
    RED_COLOR = nil;
    GREEN_COLOR = nil;
    
    //[self removeObserver:self forKeyPath:@"lapCountLabel.frame"];
    [super dealloc];
}

- (IBAction)startStopButtonPressed:(id)sender
{
    [watch startStopButtonPressed];
    
    if (watch.bTimerRunning) {
        // START BUTTON
        [self flashBackground];
        [self updateButtonState];
        
        if (sender == startStopButton) {
            // play click sound
            [appDelegate playClickSound];
        }
    } else {
        // STOP BUTTON
        [self flashBackground];
        [self updateButtonState];
        
        if (sender == startStopButton)
        {
            // play click sound
            [appDelegate playClickSound];
        }
        
        // update the lapCountLabel
        int intervalDistance = (int)appDelegate.multiStopwatchViewController.intervalDistance;
        int iEventType = (int)appDelegate.multiStopwatchViewController.iUnits;
        BOOL bFurlongMode = appDelegate.multiStopwatchViewController.bFurlongMode;
        
        // v2.2 change - show completed distance instead of lap count
        completedDistanceLabel.text = [Utilities stringFromDistance:watch.lapCount*intervalDistance Units:iEventType ShowSplitTag:NO Interval:intervalDistance FurlongDisplayMode:bFurlongMode];
        completedDistanceTime.text = @"";
        
        // v1.2 change - instead of committing to the database on final stop
        //				 we commit each watch on reset
        
        // will commit all watches to the database
        // if this was the last running watch
        //[appDelegate.multiStopwatchViewController addAllEventsToDatabase];
    }
}

- (IBAction)lapResetButtonPressed:(id)sender
{
    if (sender == lapResetButton) {
        // play click sound
        [appDelegate playClickSound];
    }
    
    [watch lapResetButtonPressed];
    
    if (watch.bTimerRunning) {
        // LAP BUTTON
        lastLapButtonPressTime = [NSDate timeIntervalSinceReferenceDate];
        
        if ([appDelegate.settingsViewController isSetForLapDelay])
        {
            // if watch is running then temporarily disable the lap button (2 sec) to prevent an inadvertent double-hit
            lapResetButton.enabled = NO;
        }
        
        // flash the cell
        [self flashBackground];
        [self freezeLapDisplay];
        [self disableLapButton];	// if enabled
        
        // update the lapCountLabel
        int intervalDistance = (int)appDelegate.multiStopwatchViewController.intervalDistance;
        int iEventType = (int)appDelegate.multiStopwatchViewController.iUnits;
        BOOL bFurlongMode = appDelegate.multiStopwatchViewController.bFurlongMode;
        
        //lapCountLabel.text = [Utilities formatLap:watch.lapCount];
        if (watch.lapCount > 0) {
            completedDistanceLabel.text = [Utilities stringFromDistance:watch.lapCount*intervalDistance Units:iEventType ShowSplitTag:NO Interval:intervalDistance FurlongDisplayMode:bFurlongMode];
            completedDistanceTime.text = [Utilities timeTextForRow:watch.splits.count-1 forDisplayMode:kDisplayMode_Normal forSplits:watch.splits forIntervalDistance:intervalDistance forUnits:intervalDistance forFurlongMode:bFurlongMode];
        } else {
            completedDistanceLabel.text = @"";
            completedDistanceTime.text = @"";
        }
        
    } else {
        // RESET BUTTON
        runningTimeLabel.text = [Utilities shortFormatTime:0 precision:2];
        lapTimeLabel.text = @"";
        //lapCountLabel.text = [Utilities formatLap:0];
        completedDistanceLabel.text = @"";
        completedDistanceTime.text = @"";
        
        [self updateButtonState];
        
        // notify the multiStopwatchTableViewController
        //[multiStopwatchTableViewController aWatchReset:self];
        if (sender == lapResetButton)
        {
            [appDelegate.multiStopwatchViewController.multiStopwatchTableViewController aWatchReset:nil];
        }
    }
}

- (void)updateTimeDisplays
{
    if (watch.bTimerRunning) {
        runningTimeLabel.text = [Utilities shortFormatTime:watch.currentRunningTime precision:2];
        
        if (watch.currentRunningTime != watch.currentLapTime) {
            if (bLapFreeze) {
                lapTimeLabel.text = [Utilities shortFormatTime:(watch.lapTime - watch.previousLapTime) precision:2];
            } else {
                lapTimeLabel.text = [Utilities shortFormatTime:watch.currentLapTime precision:2];
            }
        }
        else {
            lapTimeLabel.text = @"";
        }
    } else {
        runningTimeLabel.text = [Utilities shortFormatTime:watch.elapsedTime precision:2];
        
        NSTimeInterval lapTime = watch.lapTime - watch.previousLapTime;
        
        if (lapTime > 0 && watch.elapsedTime != lapTime) {
            lapTimeLabel.text = [Utilities shortFormatTime:lapTime precision:2];
        }
    }
}

- (void)updateButtonState
{
    //[self updateTimeDisplays];
    
    if (watch.bTimerRunning)
    {
        [startStopButton setEnabled:YES];
        [lapResetButton setEnabled:YES];
        [startStopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
        [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
        startStopButton.layer.borderColor = RED_COLOR.CGColor;
        [lapResetButton setTitle:NSLocalizedString(@"Lap", nil) forState:UIControlStateNormal];
    }
    else
    {
        if (watch.lapCount > 0)
        {
            [startStopButton setEnabled:NO];
            [startStopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
            [startStopButton setTitleColor:RED_COLOR forState:UIControlStateNormal];
            startStopButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            [lapResetButton setEnabled:YES];
            [lapResetButton setTitle:NSLocalizedString(@"Reset", nil) forState:UIControlStateNormal];
        }
        else
        {
            [startStopButton setEnabled:YES];
            [startStopButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
            [startStopButton setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
            startStopButton.layer.borderColor = GREEN_COLOR.CGColor;
            [lapResetButton setTitle:NSLocalizedString(@"Lap", nil) forState:UIControlStateNormal];
        }
        
        [lapResetButton setEnabled:YES];
        lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
    }
    
}

// disable the lap button for 2.0 seconds (if enabled in current settings)
- (void)disableLapButton
{
    if ([appDelegate.settingsViewController isSetForLapDelay])
    {
        lapResetButton.enabled = NO;
        lapResetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                          target: self
                                                        selector: @selector(enableLapButton)
                                                        userInfo: nil
                                                         repeats: NO];
        
        // this will allow the timer to fire on any loop in case the user is scrolling
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)enableLapButton
{
    lapResetButton.enabled = YES;
    lapResetButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)setWatchButtonBehavior
{
    [startStopButton removeTarget:self action:@selector(startStopButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [startStopButton removeTarget:self action:@selector(startStopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if ([appDelegate isSetForTouchUpStart])
    {
        [startStopButton addTarget:self action:@selector(startStopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [startStopButton addTarget:self action:@selector(startStopButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
    
    [lapResetButton removeTarget:self action:@selector(lapResetButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [lapResetButton removeTarget:self action:@selector(lapResetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if ([appDelegate isSetForTouchUpLap])
    {
        [lapResetButton addTarget:self action:@selector(lapResetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [lapResetButton addTarget:self action:@selector(lapResetButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
}

// flash the background for 0.08 seconds
- (void)flashBackground
{
    backgroundView.backgroundColor = [UIColor darkGrayColor];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 0.08
                                                      target: self
                                                    selector: @selector(unflashBackground)
                                                    userInfo: nil
                                                     repeats: NO];
    
    // this will allow the timer to fire on any loop in case the user is scrolling
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)unflashBackground
{
    backgroundView.backgroundColor = [UIColor whiteColor];
}

// freeze lap display for 5.0 seconds
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

@end
