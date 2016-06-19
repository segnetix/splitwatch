//
//  SplitDetailCell.h
//  Stopwatch
//
//  Created by Steven Gentry on 11/9/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import <UIKit/UIKit.h>


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
}

@property (nonatomic, retain) IBOutlet UILabel *lapColumn;
@property (nonatomic, retain) IBOutlet UILabel *timeColumn;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn1;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn2;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn3;
@property (nonatomic, retain) IBOutlet UILabel *splitColumn4;
@property (nonatomic, retain) UIImage *accDisclosureImage;
@property (nonatomic, retain) UIImageView *accImageView;
@property (nonatomic, retain) UIImage *separatorImage;
@property (nonatomic, retain) UIImageView *separatorImageView;

- (void)additionalSetup;

@end
