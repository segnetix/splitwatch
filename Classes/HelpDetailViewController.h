//
//  HelpDetailViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 2/22/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define	kSplitwatchMode		1
#define kMultiwatchMode		2
#define kHistoryMode		3
#define kSettingsMode		4

@class StopwatchAppDelegate;

@interface HelpDetailViewController : UIViewController
{
	NSInteger helpMode;
	
	StopwatchAppDelegate *appDelegate;
}

@property NSInteger helpMode;
@property (nonatomic, assign) StopwatchAppDelegate *appDelegate;

- (id)initWithMode:(NSInteger)mode;

@end