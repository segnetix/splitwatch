//
//  AboutViewController.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/14/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AboutViewController : UIViewController <UIAlertViewDelegate>
{
	UILabel *versionLabel;
	UILabel *timingEventCountLabel;
	UILabel *splitCountLabel;
	UILabel *dbFileSizeLabel;
	UILabel *dbVersionLabel;	// v1.2
    IBOutlet UIButton *clearTimingDataButton;
	
	sqlite3 *database;
}

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UILabel *timingEventCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *splitCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *dbFileSizeLabel;
@property (nonatomic, retain) IBOutlet UILabel *dbVersionLabel;
@property (retain, nonatomic) IBOutlet UIButton *clearTimingDataButton;

- (void)updateDatabaseStats;
- (NSInteger)getCountFrom:(NSString *)tableName;
- (IBAction)clearTimingData:(id)sender;

@end