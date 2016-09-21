//
//  SettingsViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/3/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "SettingsViewController.h"
#import "StopwatchAppDelegate.h"

@implementation SettingsViewController

@synthesize lapIntervalControl;
@synthesize unitsControl;
@synthesize kiloControl;
@synthesize	furlongDisplayControl;
@synthesize soundControl;
@synthesize lapDelayControl;
@synthesize touchUpStartControl;
@synthesize touchUpLapControl;
@synthesize aboutButton;
@synthesize helpButton;
@synthesize aboutViewController;
@synthesize helpViewController;
@synthesize emailAddressViewController;
@synthesize backgroundImageView;
@synthesize emailSetButton;
@synthesize rootDataFilePath;
@synthesize bLoaded;

@synthesize unitsState;
@synthesize intervalState;
@synthesize kiloSplitsState;
@synthesize furlongDisplayState;
@synthesize soundState;
@synthesize lapDelayState;
@synthesize touchUpStartState;
@synthesize touchUpLapState;
@synthesize emailAddressItems;
@synthesize appDelegate;

- (id)init
{
	if (self = [super initWithNibName:@"Settings" bundle:nil])
	{
		// additional initialization
		emailAddressItems = [[NSMutableArray alloc] initWithCapacity:5];
		
		// default settings
		unitsState = kMetric;
		intervalState = k200mLapInterval;
		kiloSplitsState = kControlOff;
		furlongDisplayState = kControlOff;
		soundState = kControlOn;
		lapDelayState = kControlOn;
		touchUpStartState = kControlOff;
		touchUpLapState = kControlOff;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
	}
	
    return self;
}

- (void)dealloc
{
    [emailAddressItems release];
    [rootDataFilePath release];
    [emailSetButton release];
    [backgroundImageView release];
    [touchUpStartControl release];
    [aboutViewController release];
    [lapIntervalControl release];
    [furlongDisplayControl release];
    [helpButton release];
    [soundControl release];
    [aboutButton release];
    [lapDelayControl release];
    [emailAddressViewController release];
    [kiloControl release];
    [touchUpLapControl release];
    [unitsControl release];
    [helpViewController release];
    
    emailAddressItems = nil;
    rootDataFilePath = nil;
    emailSetButton = nil;
    backgroundImageView = nil;
    touchUpStartControl = nil;
    aboutViewController = nil;
    lapIntervalControl = nil;
	furlongDisplayControl = nil;
    helpButton = nil;
    soundControl = nil;
    aboutButton = nil;
    lapDelayControl = nil;
    emailAddressViewController = nil;
    kiloControl = nil;
    touchUpLapControl = nil;
    unitsControl = nil;
    helpViewController = nil;
	
    [super dealloc];
}

- (NSInteger)getLapInterval
{
	NSInteger lapInterval = 0;
	NSInteger lapIndex = intervalState;
	
	if (lapIntervalControl != nil)
		lapIndex = [lapIntervalControl selectedSegmentIndex]; 

	if ([self isSetForMetricUnits])
	{
		switch (lapIndex)
		{
			case k25mLapInterval:	lapInterval =  25;	break;
			case k50mLapInterval:	lapInterval =  50;	break;
			case k100mLapInterval:	lapInterval = 100;	break;
			case k200mLapInterval:	lapInterval = 200;	break;
			case k400mLapInterval:	lapInterval = 400;	break;
			default:				lapInterval =   0;	break;
		}
	}
	else if ([self isSetForEnglishUnits])
	{
		switch (lapIndex)
		{
			case k25yLapInterval:	lapInterval =  25;	break;
			case k50yLapInterval:	lapInterval =  50;	break;
			case k110yLapInterval:	lapInterval = 110;	break;
			case k220yLapInterval:	lapInterval = 220;	break;
			case k440yLapInterval:	lapInterval = 440;	break;
			default:				lapInterval =   0;	break;
		}
	}
	else	// v1.2 - Lap mode
	{
		lapInterval = 1;
	}

	return lapInterval;
}

- (NSArray *)getDefaultEmailAddresses
{
	return emailAddressItems;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(bottomSeparatorImageView);
    
    // separator line between the settings view and the tab bar
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
    
	if (!bLoaded)
	{
		unitsControl.selectedSegmentIndex = unitsState;
		lapIntervalControl.selectedSegmentIndex = intervalState;
		kiloControl.on = (kiloSplitsState == kControlOn);
		furlongDisplayControl.on = (furlongDisplayState == kControlOn);
		soundControl.on = (soundState == kControlOn);
		lapDelayControl.on = (lapDelayState == kControlOn);
		touchUpStartControl.on = (touchUpStartState == kControlOn);
		touchUpLapControl.on = (touchUpLapState == kControlOn);
		
		if (unitsState != kMetric || intervalState != k200mLapInterval)
		{
			kiloControl.on = NO;
			kiloControl.enabled = NO;
		}
		
		// v1.2
		if (unitsState != kEnglish || (intervalState != k220yLapInterval && intervalState != k440yLapInterval))
		{
			furlongDisplayControl.on = NO;
			furlongDisplayControl.enabled = NO;
		}
		
		// save state
		intervalSelectedSegmentIndex = (int)lapIntervalControl.selectedSegmentIndex;
		
		bLoaded = YES;
		
		[self clickedUnitsSelector:self];		
	}	
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	// BUG FIX: lapIntervalControl was losing state
	unitsControl.selectedSegmentIndex = unitsState;
	lapIntervalControl.selectedSegmentIndex = intervalState;
	kiloControl.on = (kiloSplitsState == kControlOn);
	furlongDisplayControl.on = (furlongDisplayState == kControlOn);
	soundControl.on = (soundState == kControlOn);
	lapDelayControl.on = (lapDelayState == kControlOn);
	touchUpStartControl.on = (touchUpStartState == kControlOn);
	touchUpLapControl.on = (touchUpLapState == kControlOn);

	[self clickedUnitsSelector:nil];
	
	[super viewWillAppear:animated];
}

- (IBAction)clickedUnitsSelector:(id)sender
{
	//[appDelegate playClickSound];
	
	if ([self isSetForMetricUnits])
	{
		[lapIntervalControl setTitle:NSLocalizedString(@"25m",  nil) forSegmentAtIndex:k25mLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"50m",  nil) forSegmentAtIndex:k50mLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"100m", nil) forSegmentAtIndex:k100mLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"200m", nil) forSegmentAtIndex:k200mLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"400m", nil) forSegmentAtIndex:k400mLapInterval];
		
		lapIntervalControl.enabled = YES;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = intervalSelectedSegmentIndex;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = k200mLapInterval;
		
		if ([lapIntervalControl selectedSegmentIndex] == k200mLapInterval)
		{
			kiloControl.enabled = YES;
		}
		else
		{
			kiloControl.enabled = NO;
			kiloControl.on = NO;
		}
		
		// v1.2
		furlongDisplayControl.enabled = NO;
		furlongDisplayControl.on = NO;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = intervalSelectedSegmentIndex;
	}
	else if ([self isSetForEnglishUnits])
	{
		[lapIntervalControl setTitle:NSLocalizedString(@"25y",  nil) forSegmentAtIndex:k25yLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"50y",  nil) forSegmentAtIndex:k50yLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"110y", nil) forSegmentAtIndex:k110yLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"220y", nil) forSegmentAtIndex:k220yLapInterval];
		[lapIntervalControl setTitle:NSLocalizedString(@"440y", nil) forSegmentAtIndex:k440yLapInterval];
		
		lapIntervalControl.enabled = YES;
		kiloControl.enabled = NO;
		kiloControl.on = NO;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = intervalSelectedSegmentIndex;
		
		if (lapIntervalControl.selectedSegmentIndex < 0)
			lapIntervalControl.selectedSegmentIndex = k220yLapInterval;

		// v1.2
		if ([lapIntervalControl selectedSegmentIndex] == k220yLapInterval || 
			[lapIntervalControl selectedSegmentIndex] == k440yLapInterval)
		{
			furlongDisplayControl.enabled = YES;
		}
		else
		{
			furlongDisplayControl.enabled = NO;
			furlongDisplayControl.on = NO;
		}
	}
	else	// v1.2 - Lap mode
	{
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:0];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:1];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:2];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:3];
		[lapIntervalControl setTitle:@"" forSegmentAtIndex:4];
		
		lapIntervalControl.selectedSegmentIndex = -1;
		lapIntervalControl.enabled = NO;
		
		kiloControl.enabled = NO;
		kiloControl.on = NO;
		
		furlongDisplayControl.enabled = NO;
		furlongDisplayControl.on = NO;
	}
	
	// hold units state
	unitsState = [unitsControl selectedSegmentIndex];
}

- (IBAction)clickedIntervalSelector:(id)sender
{
	//[appDelegate playClickSound];
	
	if (lapIntervalControl.selectedSegmentIndex > -1)
		intervalSelectedSegmentIndex = (int)lapIntervalControl.selectedSegmentIndex;
	
	// only metric 200m setting allows kilo splits
	if ([unitsControl selectedSegmentIndex] == kMetric &&
		[lapIntervalControl selectedSegmentIndex] == k200mLapInterval)
	{
		kiloControl.enabled = YES;
	}
	else
	{
		kiloControl.enabled = NO;
		kiloControl.on = NO;
	}
	
	// v1.2
	if ([unitsControl selectedSegmentIndex] == kEnglish &&
		([lapIntervalControl selectedSegmentIndex] == k220yLapInterval ||
		 [lapIntervalControl selectedSegmentIndex] == k440yLapInterval))
	{
		furlongDisplayControl.enabled = YES;
	}
	else
	{
		furlongDisplayControl.enabled = NO;
		furlongDisplayControl.on = NO;
	}
	
	// BUG FIX: hold interval state
	intervalState = [lapIntervalControl selectedSegmentIndex];
}

- (IBAction)clickedKiloControl:(id)sender
{
	//[appDelegate playClickSound];
	
	kiloSplitsState = (kiloControl.enabled && [kiloControl isOn]);
}

- (IBAction)clickedFurlongDisplayControl:(id)sender
{
	//[appDelegate playClickSound];
	
	furlongDisplayState = (furlongDisplayControl.enabled && [furlongDisplayControl isOn]);
}

- (IBAction)clickedSoundControl:(id)sender
{
	soundState = [soundControl isOn];
	[appDelegate playClickSound];
}

- (IBAction)clickedLapDelayControl:(id)sender
{
	//[appDelegate playClickSound];
	lapDelayState = [lapDelayControl isOn];
}

- (IBAction)clickedTouchUpStartControl:(id)sender
{
	//[appDelegate playClickSound];
	touchUpStartState = [touchUpStartControl isOn];
}

- (IBAction)clickedTouchUpLapControl:(id)sender
{
	//[appDelegate playClickSound];
	touchUpLapState = [touchUpLapControl isOn];
}

- (IBAction)clickedAboutButton:(id)sender
{
	//[appDelegate playClickSound];
	aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	aboutViewController.navigationItem.title = NSLocalizedString(@"About", nil);
	
	[self.navigationController pushViewController:aboutViewController animated:YES];
	[aboutViewController release];
}

- (IBAction)clickedHelpButton:(id)sender
{
	//[appDelegate playClickSound];
	helpViewController = [[HelpViewController alloc] init];
	
	[self.navigationController pushViewController:helpViewController animated:YES];
	[helpViewController release];
}

- (IBAction)clickedEmailSetButton:(id)sender
{
	//[appDelegate playClickSound];
	emailAddressViewController = [[EmailAddressViewController alloc] initWithEmailAddressItemsArray:self.emailAddressItems];
	
	[self.navigationController pushViewController:emailAddressViewController animated:YES];
	[emailAddressViewController release];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
}

- (BOOL)isSetForMetricUnits
{
	BOOL bMetricUnits = (unitsState == kMetric);
	
	if (unitsControl != nil)
		bMetricUnits = (unitsControl.selectedSegmentIndex == kMetric);
	
	return bMetricUnits;
}

// v1.2
- (BOOL)isSetForEnglishUnits
{
	BOOL bEnglishUnits = (unitsState == kEnglish);
	
	if (unitsControl != nil)
		bEnglishUnits = (unitsControl.selectedSegmentIndex == kEnglish);
	
	return bEnglishUnits;
}

// v1.2
- (BOOL)isSetForLapUnits
{
	BOOL bLapUnits = (unitsState == kLap);
	
	if (unitsControl != nil)
		bLapUnits = (unitsControl.selectedSegmentIndex == kLap);
	
	return bLapUnits;
}

// v1.2
- (int)intervalUnits
{
	int units = (int)unitsState;
	
	if (unitsControl != nil)
		units = (int)unitsControl.selectedSegmentIndex;
	
	return units;
}

- (BOOL)isSetForKiloSplits
{
	BOOL bKiloUnits = (kiloSplitsState == kControlOn);
	
	if (kiloControl != nil)
		bKiloUnits = (kiloControl.enabled && [kiloControl isOn]);

	return bKiloUnits;
}

// v1.2
- (BOOL)isSetForFurlongDisplay
{
	BOOL bFurlongDisplay = (furlongDisplayState	== kControlOn);
	
	if (furlongDisplayControl != nil)
		bFurlongDisplay = (furlongDisplayControl.enabled && [furlongDisplayControl isOn]);
	
	return bFurlongDisplay;
}

- (BOOL)isSetForSound
{
	BOOL bSound = (soundState == kControlOn);
	
	if (soundControl != nil)
		bSound = [soundControl isOn];
	
	return bSound;
}

- (BOOL)isSetForLapDelay
{
	BOOL bLapDelay = (lapDelayState == kControlOn);
	
	if (lapDelayControl != nil)
		bLapDelay = [lapDelayControl isOn];
	
	return bLapDelay;
}

- (BOOL)isSetForTouchUpStart
{
	BOOL bTouchUpStart = (touchUpStartState == kControlOn);
	
	if (touchUpStartControl != nil)
		bTouchUpStart = [touchUpStartControl isOn];
	
	return bTouchUpStart;
}

- (BOOL)isSetForTouchUpLap
{
	BOOL bTouchUpLap = (touchUpLapState == kControlOn);
	
	if (touchUpLapControl != nil)
		bTouchUpLap = [touchUpLapControl isOn];
	
	return bTouchUpLap;
}

- (void)saveStateToFile:(NSString *)rootFilePath
{
	// save main stopwatch state
	NSArray *keys = [NSArray arrayWithObjects:
					 @"Units",
					 @"Interval",
					 @"KiloSplit",
					 @"FurlongDisplay",
					 @"Sound",
					 @"LapDelay",
					 @"TouchUpStart",
					 @"TouchUpLap",
					 @"Email",
					 nil];
	
	NSNumber *units = [NSNumber numberWithInt:(int)unitsState];
	NSNumber *interval = [NSNumber numberWithInt:(int)intervalState];
	NSNumber *kiloSplits =  [NSNumber numberWithInt:(int)kiloSplitsState];
	NSNumber *furlongDisplay = [NSNumber numberWithInt:(int)furlongDisplayState];
	NSNumber *sound =  [NSNumber numberWithInt:(int)soundState];
	NSNumber *lapDelay =  [NSNumber numberWithInt:(int)lapDelayState];
	NSNumber *touchUpStart =  [NSNumber numberWithInt:(int)touchUpStartState];
	NSNumber *touchUpLap =  [NSNumber numberWithInt:(int)touchUpLapState];
	
	NSArray *objects = [NSArray arrayWithObjects:
						units,
						interval,
						kiloSplits,
						furlongDisplay,
						sound,
						lapDelay,
						touchUpStart,
						touchUpLap,
						emailAddressItems,
						nil];
	
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	NSString *filePath = [rootFilePath stringByAppendingPathComponent:@"SettingsData.plist"];
	
	[dataDictionary writeToFile:filePath atomically:YES];
	[dataDictionary release];	
}

- (void)loadStateFromFile:(NSString *)rootFilePath
{
	self.rootDataFilePath = rootFilePath;
	
	// load settings from plist
	NSString *filePath = [rootDataFilePath stringByAppendingPathComponent:@"SettingsData.plist"];
	
	NSDictionary *dataDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	
	if (dataDictionary != nil)
	{
		NSNumber *units = [dataDictionary objectForKey:@"Units"];
		NSNumber *interval = [dataDictionary objectForKey:@"Interval"];
		NSNumber *kiloSplits = [dataDictionary objectForKey:@"KiloSplit"];
		NSNumber *furlongDisplay = [dataDictionary objectForKey:@"FurlongDisplay"];
		NSNumber *sound = [dataDictionary objectForKey:@"Sound"];
		NSNumber *lapDelay = [dataDictionary objectForKey:@"LapDelay"];
		NSNumber *touchUpStart = [dataDictionary objectForKey:@"TouchUpStart"];
		NSNumber *touchUpLap = [dataDictionary objectForKey:@"TouchUpLap"];
		[emailAddressItems addObjectsFromArray:[dataDictionary objectForKey:@"Email"]];
		
		unitsState = (NSInteger)[units intValue];
		intervalState = (NSInteger)[interval intValue];
		kiloSplitsState = (NSInteger)[kiloSplits intValue];
		furlongDisplayState = (NSInteger)[furlongDisplay intValue];
		soundState = (NSInteger)[sound intValue];
		lapDelayState = (NSInteger)[lapDelay intValue];
		touchUpStartState = (NSInteger)[touchUpStart intValue];
		touchUpLapState = (NSInteger)[touchUpLap intValue];
	}
	
	// logical filter for kilo split flag
	if (unitsState != kMetric || intervalState != k200mLapInterval)
	{
		kiloSplitsState = kControlOff;
	}
	
	// v1.2 - logical filter for furlongDisplay flag
	if (unitsState != kEnglish || (intervalState != k220yLapInterval && intervalState != k440yLapInterval))
	{
		furlongDisplayState = kControlOff;
	}
	
	bLoaded = NO;
	
	[dataDictionary release];	
}

@end
