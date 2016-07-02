//
//  StopwatchAppDelegate.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright segnetix.com 2009. All rights reserved.
//

#import "StopwatchAppDelegate.h"
#import "Utilities.h"

@implementation StopwatchAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize stopwatchViewController;
@synthesize multiStopwatchViewController;
@synthesize settingsViewController;
@synthesize database;
@synthesize dbPath;
@synthesize clickSoundID;
@synthesize clickSoundFileURLRef;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// status bar
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	
	// open the event database
	[self createEditableCopyOfDatabaseIfNeeded];
	[self validateAndOpenDatabase];
	
    tabBarController = [[UITabBarController alloc] init];
	tabBarController.delegate = self;
	
	// Tab 4 - SettingsViewController (set up first so other view controllers can access settings on init)
	UINavigationController *settingsNavigationController = [[UINavigationController alloc] init];
	settingsNavigationController.title = @"Settings";
	settingsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.title = @"Settings";
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"settings02.png"];
	
	// push on stack and release
	[settingsNavigationController pushViewController:settingsViewController animated:NO];
	
	// Tab 3 - HistoryNavController
	UINavigationController *historyNavigationController = [[UINavigationController alloc] init];
	historyNavigationController.title = @"History";
	historyNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// push the HistoryViewController on the History Nav Controller stack
    HistoryViewController *historyViewController = [[HistoryViewController alloc]
                                                    initWithSettingsViewController:settingsViewController];
	
    historyViewController.title = @"History";
    historyViewController.tabBarItem.image = [UIImage imageNamed:@"history03.png"];
	
	// this hides the "Root Level" back button in the historyViewController
	historyViewController.navigationItem.hidesBackButton = YES;
    
	// push on stack and release
	[historyNavigationController pushViewController:historyViewController animated:NO];
	
	// Tab 1 - StopwatchViewController
	stopwatchViewController = [[StopwatchViewController alloc]
							   initWithSettingsViewController:settingsViewController];
	
	stopwatchViewController.title = @"Splitwatch";
    stopwatchViewController.tabBarItem.image = [UIImage imageNamed:@"splitwatch.png"];
	
	// Tab 2 - MultiStopwatchViewController
    UINavigationController *multiStopwatchNavigationController = [[UINavigationController alloc] init];
    multiStopwatchViewController = [[MultiStopwatchViewController alloc]
                                    initWithSettingsViewController:settingsViewController];
    
	multiStopwatchViewController.title = @"Multiwatch";
    multiStopwatchNavigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    multiStopwatchViewController.tabBarItem.image = [UIImage imageNamed:@"multiwatch.png"];
	[multiStopwatchNavigationController pushViewController:multiStopwatchViewController animated:NO];
    
	// add the controllers as children of the tab bar controller
	tabBarController.viewControllers =
	[NSArray arrayWithObjects:stopwatchViewController,
	 multiStopwatchNavigationController,
	 historyNavigationController,
	 settingsNavigationController,
	 nil];
    
    UITabBar *tabBar = [tabBarController tabBar];
    
    tabBar.barStyle = UIBarStyleDefault;
    tabBar.translucent = YES;
    
	// release allocated controllers
	[stopwatchViewController release];
	[multiStopwatchViewController release];
    [multiStopwatchNavigationController release];
	[historyNavigationController release];
	[historyViewController release];
	[settingsNavigationController release];
	[settingsViewController release];
	
	// add the tab bar controller's view to the window
	//[window addSubview:tabBarController.view];
    //tabBarController.view.translatesAutoresizingMaskIntoConstraints = YES;
    [self.window setRootViewController:tabBarController];
    [window makeKeyAndVisible];
    
	// load click sound data
	CFBundleRef mainBundle;
	mainBundle = CFBundleGetMainBundle ();
	clickSoundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("Tink"), CFSTR("wav"), NULL);
	AudioServicesCreateSystemSoundID(clickSoundFileURLRef, &clickSoundID);
	
	[self loadAppStateFromDisk];	
	
	// to preload the sound (if sound enabled)
	[self playClickSound];

	return YES;
}

- (void)dealloc
{
    [tabBarController release];
    [window release];

	AudioServicesDisposeSystemSoundID(self.clickSoundID);
    CFRelease(clickSoundFileURLRef);
	
    [super dealloc];
}

- (void)playClickSound
{
	if ([settingsViewController isSetForSound] == YES)
	{
		AudioServicesPlaySystemSound(self.clickSoundID);
	}
}

- (BOOL)isSetForTouchUpStart
{
	return [settingsViewController isSetForTouchUpStart];
}

- (BOOL)isSetForTouchUpLap
{
	return [settingsViewController isSetForTouchUpLap];
}

- (NSString *)documentDirectoryFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return documentsDirectory;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSString *rootFilePath = [self documentDirectoryFilePath];
	
	[self saveStateToFile:rootFilePath];
	[stopwatchViewController saveStateToFile:rootFilePath];
	[multiStopwatchViewController saveStateToFile:rootFilePath];
	[settingsViewController saveStateToFile:rootFilePath];
	
	sqlite3_close(database);
	database = nil;
}

// v1.2 - 
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"applicationDidEnterBackground");
	
	NSString *rootFilePath = [self documentDirectoryFilePath];
	
	[self saveStateToFile:rootFilePath];
	[stopwatchViewController saveStateToFile:rootFilePath];
	[multiStopwatchViewController saveStateToFile:rootFilePath];
	[settingsViewController saveStateToFile:rootFilePath];
}

// v1.2 - 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	
}

- (void)loadAppStateFromDisk
{
	// load app state
	NSString *rootFilePath = [self documentDirectoryFilePath];

	[settingsViewController loadStateFromFile:rootFilePath];
	[stopwatchViewController loadStateFromFile:rootFilePath];
	[multiStopwatchViewController loadStateFromFile:rootFilePath];
	[self loadStateFromFile:rootFilePath];
}

- (void)saveStateToFile:(NSString *)rootFilePath
{
	// save main stopwatch state
	NSArray *keys = [NSArray arrayWithObjects:
					 @"StartTabIndex",
					 nil];
	
	NSNumber *startTabIndex = [NSNumber numberWithInt:(int)tabBarController.selectedIndex];
	
	NSArray *objects = [NSArray arrayWithObjects:
						startTabIndex,
						nil];
	
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"AppStateData.plist"];
	
	[dataDictionary writeToFile:filePath atomically:YES];
	[dataDictionary release];
}

- (void)loadStateFromFile:(NSString *)rootFilePath
{
	NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"AppStateData.plist"];
	
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	
	NSNumber *startTabIndex = [dataDictionary objectForKey:@"StartTabIndex"];
	
	if (startTabIndex == nil)
	{
		tabBarController.selectedIndex = 0;
	}
	else
	{
		tabBarController.selectedIndex = [startTabIndex intValue];
	}
	
	[dataDictionary release];	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	// can we release any extra memory?
	
    /*
	// TESTING - memory warning alert
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"StopwatchAppDelegate received a memory warning."
														message:@""
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
     */
}


// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	//[self playClickSound];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

#pragma mark -
#pragma mark Database Methods

- (void)createEditableCopyOfDatabaseIfNeeded
{
	// test for existence of writable database
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *documentsDirectory = [self documentDirectoryFilePath];
	NSString *writeableDBPath = [documentsDirectory stringByAppendingPathComponent:@"EventData.db"];
	
	success = [fileManager fileExistsAtPath:writeableDBPath];
	
	if (success)
		return;
	
	/*
	 // temp code for testing...
	 // this line will remove the existing db (simulator or device) and copy
	 // the bundle version to the documents directory
	 //success = [fileManager removeItemAtPath:writeableDBPath error:&error];
	 */
	
	// first time run code...
	// database does not exist in user document directory, so copy the default (bundle version) to the appropriate location
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"EventData.db"];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writeableDBPath error:&error];
	
	if (!success)
	{
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
}

// v1.0 / v1.1  - opens the database for use (was openDatabase)
// v1.2 - validates and upgrades the database to v1.2 schema
//		- adds and populates the new EventType and FurlongMode columns in the Event table
//		- adds the DBInfo table
- (void)validateAndOpenDatabase
{
	// get database from the application path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	// v1.2 - set the global path to the database
	dbPath = [documentsDirectory stringByAppendingPathComponent:@"EventData.db"];
	
	// open the database
	if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK)
	{
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		sqlite3_close(database);
		database = nil;
		return;
	}
	
	char sql[250];
	sqlite3_stmt *statement;
	
	int result1 = SQLITE_OK;
	int result2 = SQLITE_OK;
	int result3 = SQLITE_OK;
	int result4 = SQLITE_OK;
	
	// v1.2 - add DBInfo table to database (if necessary) and set the database version in the table
	// one time upgrade from database version v1.0 to 1.2
	//------------------
	
	// v1.2 - add the DBInfo table (if necessary) and set db version (for future upgrades)
	strcpy(sql, "SELECT * FROM DBInfo");
	
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		// db is missing the DBInfo table
		NSString *createSql = @"CREATE  TABLE 'main'.'DBInfo' ('DBVersion' TEXT)";
		
		if (sqlite3_exec(database, [createSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL) == SQLITE_OK)
		{
			NSString *insertSQL = @"INSERT INTO DBInfo VALUES ('1.2')";
			sqlite3_exec(database, [insertSQL cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
		}
		else
		{
			NSAssert1(0, @"Failed to add the DBInfo table with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_finalize(statement);
	
	// v1.2 - add EventType and FurlongMode columns to Event table
	//------------------
	// check for EventType column -- update if necessary
	strcpy(sql, "SELECT EventType FROM Event");
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		// db is missing the EventType column so must be a pre v1.2 database
		//------------------
		// EventType
		NSString *createSql = @"ALTER TABLE Event ADD COLUMN EventType INTEGER";
		if (sqlite3_exec(database, [createSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL) == SQLITE_OK)
		{
			NSString *updateSQL = @"UPDATE Event SET EventType = 0 WHERE MetricUnits = 1";
			result1 = sqlite3_exec(database, [updateSQL cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
			
			updateSQL = @"UPDATE Event SET EventType = 1 WHERE MetricUnits <> 1";
			result2 = sqlite3_exec(database, [updateSQL cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
		}
		else
		{
			NSAssert1(0, @"Failed to add the EventType column with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	// add Split table index if necessary
	NSString *updateSQL = @"CREATE INDEX IF NOT EXISTS idx1 ON Split(EventNum)";
	result3 = sqlite3_exec(database, [updateSQL cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
			
	sqlite3_finalize(statement);
	
	// check for FurlongMode column -- update if necessary
	strcpy(sql, "SELECT FurlongMode FROM Event");
	
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		// FurlongMode
		NSString *createSql = @"ALTER TABLE Event ADD COLUMN FurlongMode INTEGER";
		if (sqlite3_exec(database, [createSql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL) == SQLITE_OK)
		{
			NSString *updateSQL = @"UPDATE Event SET FurlongMode = 0";
			result4 = sqlite3_exec(database, [updateSQL cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
		}
		else
		{
			NSAssert1(0, @"Failed to add the Furlong column with message '%s'.", sqlite3_errmsg(database));
		}
	}
	
	sqlite3_finalize(statement);
	
	if (result1 == SQLITE_OK && result2 == SQLITE_OK && result3 == SQLITE_OK && result4 == SQLITE_OK)
		NSLog(@"Running with db version %@", [self	getDatabaseVersion]);
	else
		NSLog(@"Upgrade to v1.2 failed.  Error code %i %i %i", result1, result2, result3);
}

- (sqlite3 *)getEventDatabase
{
	return self.database;
}

- (unsigned long long)getSqliteFileSize
{
	// test for existence of writable database
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *documentsDirectory = [self documentDirectoryFilePath];
	NSString *writeableDBPath = [documentsDirectory stringByAppendingPathComponent:@"EventData.db"];
	
	success = [fileManager fileExistsAtPath:writeableDBPath];
	
	if (success)
	{
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:writeableDBPath error:&error];
		unsigned long long fileSize = [fileAttributes fileSize];
		
		return fileSize;
	}
	
	return 0;
}

- (NSString *)getDatabaseVersion
{
	char sql[250];
	sqlite3_stmt *statement;
	NSString *dbVersionStr = @"";
	
	strcpy(sql, "SELECT DBVersion FROM DBInfo");
	
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		//NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
	}
	
	// step through the result set row
	if (sqlite3_step(statement) == SQLITE_ROW)
	{
		dbVersionStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
	}
	
	sqlite3_finalize(statement);
	
	return dbVersionStr;
}

// returns event info based on the given selection filter
- (NSArray *)getEventInfoArrayBasedOnSelection:(NSInteger)selection withFilter:(NSString *)filter
{	
	char sql[250];
	sqlite3_stmt *statement;
	
	switch (selection) {
		case kDate:			// Date
			strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance FROM Event WHERE date(EventDateTime)=? ORDER BY EventDateTime DESC");
			break;
		case kDistance:		// Distance
			// if 25 or 50 we need to determine if metric (m) or english (y) and select with MetricUnits
			if ([filter rangeOfString:@"m"].location != NSNotFound)
				strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE EventDistance=? AND EventType=0 ORDER BY EventDateTime DESC");
			else if ([filter rangeOfString:@"y"].location != NSNotFound || [filter rangeOfString:@"-Mile"].location != NSNotFound)
				strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE EventDistance=? AND EventType=1 AND FurlongMode=0 ORDER BY EventDateTime DESC");
			else if ([filter rangeOfString:@"/"].location != NSNotFound || [filter rangeOfString:@"-M"].location != NSNotFound)
				strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE EventDistance=? AND EventType=1 AND FurlongMode=1 ORDER BY EventDateTime DESC");
			else
				strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE EventDistance=? AND EventType=2 ORDER BY EventDateTime DESC");
			
			// strip any 'm' or 'y' at the end of the filterClause
			filter = [filter stringByReplacingOccurrencesOfString:@"m" withString:@""];
			filter = [filter stringByReplacingOccurrencesOfString:@"y" withString:@""];
			
			// reset the filter - convert English miles and furlong fractions back to yards for the EventDistance WHERE clause
			if ([filter rangeOfString:@"-Mile"].location != NSNotFound)
			{
				// strip out "-Mile" and reset as string with yards
				filter = [filter stringByReplacingOccurrencesOfString:@"-Mile" withString:@""];
				filter = [NSString stringWithFormat:@"%u", [filter intValue] * 1760];
			}
			else if ([filter rangeOfString:@"/"].location != NSNotFound && [filter rangeOfString:@"-"].location == NSNotFound)			// v1.2 - Furlong modes  "1/4"
			{
				// extract mile integer and fractional portions
				NSRange range = [filter rangeOfString:@"/"];
				NSString *numeratorStr = [filter substringToIndex:range.location];
				NSString *denominatorStr = [filter substringFromIndex:range.location + 1];
				filter = [NSString stringWithFormat:@"%u", ([numeratorStr intValue] * 1760) / [denominatorStr intValue]];
			}
			else if ([filter rangeOfString:@"-M"].location != NSNotFound && [filter rangeOfString:@"/"].location == NSNotFound)			// v1.2 - Furlong modes  "1-M"
			{
				// extract mile integer
				NSRange range = [filter rangeOfString:@"-M"];
				NSString *mileStr = [filter substringToIndex:range.location];
				filter = [NSString stringWithFormat:@"%u", [mileStr intValue] * 1760];
			}
			else if ([filter rangeOfString:@"/"].location != NSNotFound && [filter rangeOfString:@"-"].location != NSNotFound)			// v1.2 - Furlong modes  "1-1/4"
			{
				// extract mile integer and fractional portions
				// mile portion
				NSRange range = [filter rangeOfString:@"-"];
				NSString *mileStr = [filter substringToIndex:range.location];
				// fractional portion
				filter = [filter substringFromIndex:range.location + 1];
				range = [filter rangeOfString:@"/"];
				NSString *numeratorStr = [filter substringToIndex:range.location];
				NSString *denominatorStr = [filter substringFromIndex:range.location + 1];																												
				filter = [NSString stringWithFormat:@"%u", ([mileStr intValue] * 1760) + ([numeratorStr intValue] * 1760) / [denominatorStr intValue]];
			}
			else if ([filter rangeOfString:@"M"].location != NSNotFound)
			{
				// strip out "-M"
				filter = [filter stringByReplacingOccurrencesOfString:@"M" withString:@""];
				// extract mile integer and fractional portions
				NSRange range = [filter rangeOfString:@" "];
				NSString *mileStr = [filter substringToIndex:range.location];
				NSString *yardStr = [filter substringFromIndex:range.location + 1];
				// reset filter string
				filter = [NSString stringWithFormat:@"%u", ([mileStr intValue] * 1760) + [yardStr intValue]];
			}
			break;
		case kEventName:	// EventName
			strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE EventName=? ORDER BY EventDateTime DESC");
			break;
		case kRunnerName:	// RunnerName
			strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event WHERE RunnerName=? ORDER BY EventDateTime DESC");
			break;
		default:
			NSLog(@"ERROR: didSelectRowAtIndexPath - received invalid selection...!!!");
			return nil;
			break;
	}
	
	// third parameter is the length of the SQL string or -1 to read to the first null terminator
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		//NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
	}
	
	// bind the where clause to the statement
	if (sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to bind statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	NSMutableArray *eventInfoArray = [[[NSMutableArray alloc] init] autorelease];
	
	// step through the result set rows (one per event)
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		// temp array to hold event info which will be inserted into the tableItems array
		NSMutableArray *eventInfo = [[NSMutableArray alloc] initWithCapacity:5];
		
		// pull event info from the query result and put into the tableItems array
		NSNumber *eventNum = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
		NSString *dateStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		NSNumber *distanceNumber = [NSNumber numberWithInt:sqlite3_column_double(statement, 2)];
		NSNumber *finalTimeNumber = [NSNumber numberWithDouble:sqlite3_column_double(statement, 3)];
		NSString *runnerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
		int eventType = (int)(sqlite3_column_int(statement, 5));
		int lapDistance = (int)(sqlite3_column_int(statement, 6));
		int furlongMode= (int)(sqlite3_column_int(statement, 7));
		
		// need to convert these values to display strings
		NSString *distanceString = [Utilities stringFromDistance:[distanceNumber intValue]
														   Units:eventType ShowMiles:YES
													ShowSplitTag:NO
														Interval:lapDistance
											  FurlongDisplayMode:furlongMode];
		NSString *finalTimeString = [Utilities shortFormatTime:[finalTimeNumber doubleValue] precision:2];
		
		// add event info into the eventInfo array
		[eventInfo addObject:eventNum];
		[eventInfo addObject:dateStr];
		[eventInfo addObject:distanceString];
		[eventInfo addObject:finalTimeString];
		[eventInfo addObject:runnerName];
		
		// add eventInfo to the tableItem array
		[eventInfoArray addObject:eventInfo];
		[eventInfo release];
	}
	
	sqlite3_finalize(statement);
	
	return eventInfoArray;
}

// returns event info based on multiple selection filters
- (NSArray *)getEventInfoArrayBasedOnAthlete:(NSString *)athlete Event:(NSString *)event Date:(NSString *)date Distance:(NSString*)distance
{
    char sql[1000];
    sqlite3_stmt *statement;
    NSString *modifiedDistance = nil;
    bool bHaveAthleteFilter = NO;
    bool bHaveEventFilter = NO;
    bool bHaveDateFilter = NO;
    bool bHaveDistanceFilter = NO;
    
    // process the distance filter
    if ([distance compare:@"All"] != NSOrderedSame) {
        // strip any 'm' or 'y' at the end of the filterClause
        modifiedDistance = [distance stringByReplacingOccurrencesOfString:@"m" withString:@""];
        modifiedDistance = [modifiedDistance stringByReplacingOccurrencesOfString:@"y" withString:@""];
        
        // reset the filter - convert English miles and furlong fractions back to yards for the EventDistance WHERE clause
        if ([distance rangeOfString:@"-Mile"].location != NSNotFound)
        {
            // strip out "-Mile" and reset as string with yards
            modifiedDistance = [distance stringByReplacingOccurrencesOfString:@"-Mile" withString:@""];
            modifiedDistance = [NSString stringWithFormat:@"%u", [modifiedDistance intValue] * 1760];
        }
        else if ([distance rangeOfString:@"/"].location != NSNotFound && [distance rangeOfString:@"-"].location == NSNotFound)			// v1.2 - Furlong modes  "1/4"
        {
            // extract mile integer and fractional portions
            NSRange range = [distance rangeOfString:@"/"];
            NSString *numeratorStr = [distance substringToIndex:range.location];
            NSString *denominatorStr = [distance substringFromIndex:range.location + 1];
            modifiedDistance = [NSString stringWithFormat:@"%u", ([numeratorStr intValue] * 1760) / [denominatorStr intValue]];
        }
        else if ([distance rangeOfString:@"-M"].location != NSNotFound && [distance rangeOfString:@"/"].location == NSNotFound)			// v1.2 - Furlong modes  "1-M"
        {
            // extract mile integer
            NSRange range = [distance rangeOfString:@"-M"];
            NSString *mileStr = [distance substringToIndex:range.location];
            modifiedDistance = [NSString stringWithFormat:@"%u", [mileStr intValue] * 1760];
        }
        else if ([distance rangeOfString:@"/"].location != NSNotFound && [distance rangeOfString:@"-"].location != NSNotFound)			// v1.2 - Furlong modes  "1-1/4"
        {
            // extract mile integer and fractional portions
            // mile portion
            NSRange range = [distance rangeOfString:@"-"];
            NSString *mileStr = [distance substringToIndex:range.location];
            // fractional portion
            modifiedDistance = [distance substringFromIndex:range.location + 1];
            range = [modifiedDistance rangeOfString:@"/"];
            NSString *numeratorStr = [modifiedDistance substringToIndex:range.location];
            NSString *denominatorStr = [modifiedDistance substringFromIndex:range.location + 1];
            modifiedDistance = [NSString stringWithFormat:@"%u", ([mileStr intValue] * 1760) + ([numeratorStr intValue] * 1760) / [denominatorStr intValue]];
        }
        else if ([distance rangeOfString:@"M"].location != NSNotFound)
        {
            // strip out "-M"
            modifiedDistance = [distance stringByReplacingOccurrencesOfString:@"M" withString:@""];
            // extract mile integer and fractional portions
            NSRange range = [modifiedDistance rangeOfString:@" "];
            NSString *mileStr = [modifiedDistance substringToIndex:range.location];
            NSString *yardStr = [modifiedDistance substringFromIndex:range.location + 1];
            // reset filter string
            modifiedDistance = [NSString stringWithFormat:@"%u", ([mileStr intValue] * 1760) + [yardStr intValue]];
        }
    }
    
    // now prepare the sql select statement with multiple filters in the WHERE clause
    strcpy(sql, "SELECT EventNum, date(EventDateTime), EventDistance, EventFinalTime, RunnerName, EventType, LapDistance, FurlongMode FROM Event");
    
    int paramCount = 0;
    
    // Athlete
    if ([athlete compare:@"All"] != NSOrderedSame) {
        strcat(sql," WHERE RunnerName=?");
        paramCount++;
        bHaveAthleteFilter = YES;
    }
    
    // Event
    if ([event compare:@"All"] != NSOrderedSame) {
        if (paramCount == 0) {
            strcat(sql," WHERE");
        } else {
            strcat(sql," AND");
        }
        strcat(sql," EventName=?");
        paramCount++;
        bHaveEventFilter = YES;
    }
    
    // Date
    if ([date compare:@"All"] != NSOrderedSame) {
        if (paramCount == 0) {
            strcat(sql," WHERE");
        } else {
            strcat(sql," AND");
        }
        strcat(sql," date(EventDateTime)=?");
        paramCount++;
        bHaveDateFilter = YES;
    }
    
    // Distance
    if ([distance compare:@"All"] != NSOrderedSame) {
        if (paramCount == 0) {
            strcat(sql," WHERE");
        } else {
            strcat(sql," AND");
        }
        
        strcat(sql," EventDistance=?");
        
        // if 25 or 50 we need to determine if metric (m) or english (y) and select with MetricUnits
        if ([distance rangeOfString:@"m"].location != NSNotFound)
            strcat(sql, " AND EventType=0");
        else if ([distance rangeOfString:@"y"].location != NSNotFound || [distance rangeOfString:@"-Mile"].location != NSNotFound)
            strcat(sql, " AND EventType=1 AND FurlongMode=0");
        else if ([distance rangeOfString:@"/"].location != NSNotFound || [distance rangeOfString:@"-M"].location != NSNotFound)
            strcat(sql, " AND EventType=1 AND FurlongMode=1");
        else
            strcat(sql, " AND EventType=2");
        
        paramCount++;
        bHaveDistanceFilter = YES;
    }

    strcat(sql, " ORDER BY EventDateTime, EventFinalTime");
    
    // third parameter is the length of the SQL string or -1 to read to the first null terminator
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        //NSLog(@"ERROR: Failed to prepare statement with message %@", sqlite3_errmsg(database));
    }
    
    // bind the where clause to the statement
    int clauseCount = 1;
    
    if (bHaveAthleteFilter) {
        if (sqlite3_bind_text(statement, clauseCount++, [athlete UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to bind statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    if (bHaveEventFilter) {
        if (sqlite3_bind_text(statement, clauseCount++, [event UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to bind statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    if (bHaveDateFilter) {
        if (sqlite3_bind_text(statement, clauseCount++, [date UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to bind statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    if (bHaveDistanceFilter) {
        if (sqlite3_bind_text(statement, clauseCount++, [modifiedDistance UTF8String], -1, SQLITE_TRANSIENT) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to bind statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    NSMutableArray *eventInfoArray = [[[NSMutableArray alloc] init] autorelease];
    
    // step through the result set rows (one per event)
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        // temp array to hold event info which will be inserted into the tableItems array
        NSMutableArray *eventInfo = [[NSMutableArray alloc] initWithCapacity:5];
        
        // pull event info from the query result and put into the tableItems array
        NSNumber *eventNum = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
        NSString *dateStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSNumber *distanceNumber = [NSNumber numberWithInt:sqlite3_column_double(statement, 2)];
        NSNumber *finalTimeNumber = [NSNumber numberWithDouble:sqlite3_column_double(statement, 3)];
        NSString *runnerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        int eventType = (int)(sqlite3_column_int(statement, 5));
        int lapDistance = (int)(sqlite3_column_int(statement, 6));
        int furlongMode= (int)(sqlite3_column_int(statement, 7));
        
        // need to convert these values to display strings
        NSString *distanceString = [Utilities stringFromDistance:[distanceNumber intValue]
                                                           Units:eventType ShowMiles:YES
                                                    ShowSplitTag:NO
                                                        Interval:lapDistance
                                              FurlongDisplayMode:furlongMode];
        NSString *finalTimeString = [Utilities shortFormatTime:[finalTimeNumber doubleValue] precision:2];
        
        // add event info into the eventInfo array
        [eventInfo addObject:eventNum];
        [eventInfo addObject:dateStr];
        [eventInfo addObject:distanceString];
        [eventInfo addObject:finalTimeString];
        [eventInfo addObject:runnerName];
        
        // add eventInfo to the tableItem array
        [eventInfoArray addObject:eventInfo];
        [eventInfo release];
    }
    
    sqlite3_finalize(statement);
    
    return eventInfoArray;
}

@end

