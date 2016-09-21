//
//  SplitDetailCell.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/9/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplitDetailViewController;

typedef enum {
    kNone,
    kTimeColumnMin,
    kSplitColumn1Min,
    kSplitColumn2Min,
    kSplitColumn3Min,
    kSplitColumn4Min,
    kTimeColumnMax,
    kSplitColumn1Max,
    kSplitColumn2Max,
    kSplitColumn3Max,
    kSplitColumn4Max
} SummarySelectionType;

@interface SplitDetailCell : UITableViewCell
{
	UILabel *lapColumn;
	UILabel *timeColumn;
	UILabel *splitColumn1;
	UILabel *splitColumn2;
	UILabel *splitColumn3;
	UILabel *splitColumn4;
	
	UIImage *accDisclosureImage;
	UIImageView *accImageView;
	UIImage *separatorImage;
	UIImageView *separatorImageView;
    
    SplitDetailViewController *splitDetailViewController;
}

@property (nonatomic, retain) IBOutlet UILabel *lapColumn;
@property (nonatomic, retain) IBOutlet UILabel *timeColumn;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn1;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn2;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn3;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn4;
@property (nonatomic, assign) UIImage *accDisclosureImage;
@property (nonatomic, assign) UIImageView *accImageView;
@property (nonatomic, assign) UIImage *separatorImage;
@property (nonatomic, assign) UIImageView *separatorImageView;
@property (nonatomic, assign) SplitDetailViewController *splitDetailViewController;

- (void)additionalSetup;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
