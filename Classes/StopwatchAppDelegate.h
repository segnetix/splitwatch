//
//  StopwatchAppDelegate.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright segnetix.com 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopwatchViewController.h"
#import "MultiStopwatchViewController.h"
#import "SettingsViewController.h"
#import "HistoryViewController.h"
#import <sqlite3.h>
#include <AudioToolbox/AudioToolbox.h>

#define kAll			0
#define kDate			1
#define kDistance		2
#define kEventName		3
#define kRunnerName		4

@interface StopwatchAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UIWindow *window;	
    UITabBarController *tabBarController;
	StopwatchViewController *stopwatchViewController;
	MultiStopwatchViewController *multiStopwatchViewController;
	SettingsViewController *settingsViewController;
	
	// database holds the event data
	sqlite3 *database;
	NSString *dbPath;		// v1.2 - path to the database file
	
	// sound
	CFURLRef clickSoundFileURLRef;
	SystemSoundID clickSoundID;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) StopwatchViewController *stopwatchViewController;
@property (nonatomic, retain) MultiStopwatchViewController *multiStopwatchViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property sqlite3 *database;
@property (nonatomic, retain) NSString *dbPath;
@property (readwrite) CFURLRef clickSoundFileURLRef;
@property (readonly) SystemSoundID clickSoundID;

- (NSString *)documentDirectoryFilePath;
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)validateAndOpenDatabase;
- (void)loadAppStateFromDisk;
- (void)playClickSound;

// global app state persistence
- (void)saveStateToFile:(NSString *)rootFilePath;
- (void)loadStateFromFile:(NSString *)rootFilePath;
- (unsigned long long)getSqliteFileSize;
- (sqlite3 *)getEventDatabase;
- (NSString *)getDatabaseVersion;
- (NSArray *)getEventInfoArrayBasedOnSelection:(NSInteger)selection withFilter:(NSString *)filter;
- (BOOL)isSetForTouchUpStart;
- (BOOL)isSetForTouchUpLap;

@end
