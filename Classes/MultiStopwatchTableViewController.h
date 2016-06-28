//
//  MultiStopwatchTableViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/15/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiStopwatchViewController;
@class Stopwatch;

@interface MultiStopwatchTableViewController : UITableViewController
{
	NSMutableArray *watches;
    NSMutableArray *multiWatchCells;
	NSInteger intervalDistance;
	MultiStopwatchViewController *multiStopwatchViewController;
    UIView *snapshot;
    NSIndexPath *movingFromIndexPath;
    NSIndexPath *sourceIndexPath;
    CADisplayLink *displayLink;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    
	int iEventType;
	BOOL bKiloSplits;
	BOOL bFurlongMode;
    BOOL bLongPressActive;
}

@property (nonatomic, retain) NSMutableArray *watches;
@property (nonatomic, retain) NSMutableArray *multiWatchCells;
@property NSInteger intervalDistance;
@property (assign) MultiStopwatchViewController *multiStopwatchViewController;
@property int iEventType;
@property BOOL bKiloSplits;
@property BOOL bFurlongMode;
@property BOOL bLongPressActive;
@property (nonatomic, retain) UIView *snapshot;
@property (nonatomic, retain) NSIndexPath *movingFromIndexPath;
@property (nonatomic, retain) NSIndexPath *sourceIndexPath;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGestureRecognizer;

- (id)initWithIntervalDistance:(NSInteger)distance
				   eventType:(int)eventType
					kiloSplits:(BOOL)kiloSplits
				   furlongMode:(BOOL)furlongMode
  multiStopwatchViewController:(MultiStopwatchViewController *)multiStopwatchVC;

- (void)resetLapInterval:(NSInteger)distance eventType:(int)eventType kiloSplits:(BOOL)kiloSplits furlongMode:(BOOL)furlongMode;
- (void)setupWatchesWithRunnerNames:(NSArray *)namesArray EventName:(NSString *)eventName;
- (NSMutableArray *)getWatchStateData;
- (void)setWatchStateData:(NSArray *)watchDataArray;

- (void)startAllWatches:(NSTimeInterval)time;
- (void)stopAllWatches:(NSTimeInterval)time;
- (void)resetAllWatches;
- (void)setWatchButtonBehavior;
- (BOOL)allWatchesReset;

- (UIView*)snapshotFromView:(UIView*)inputView;

- (void)aWatchStarted:(Stopwatch *)watch;
- (void)aWatchStopped:(Stopwatch *)watch;
- (void)aWatchReset:(Stopwatch *)watch;

- (void)addAllEventsToDatabase;

@end
