//
//  SplitDetailCell.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/9/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "SplitDetailCell.h"
#import "Utilities.h"

@implementation SplitDetailCell

@synthesize lapColumn;
@synthesize timeColumn;
@synthesize splitColumn1;
@synthesize splitColumn2;
@synthesize splitColumn3;
@synthesize splitColumn4;
@synthesize accDisclosureImage;
@synthesize accImageView;
@synthesize separatorImage;
@synthesize separatorImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		// initialization
    }
	
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
	[lapColumn release];
	[timeColumn release];
	[splitColumn1 release];
	[splitColumn2 release];
	[splitColumn3 release];
	[splitColumn4 release];
	
	lapColumn = nil;
	timeColumn = nil;
	splitColumn1 = nil;
	splitColumn2 = nil;
	splitColumn3 = nil;
	splitColumn4 = nil;
	accDisclosureImage = nil;
	accImageView = nil;
	separatorImage = nil;
	separatorImageView = nil;
	
    [super dealloc];
}

- (void)additionalSetup
{	
	accDisclosureImage = [UIImage imageNamed:@"AccDisclosure.png"];
	accImageView = [[UIImageView alloc] initWithImage:accDisclosureImage];
    accImageView.translatesAutoresizingMaskIntoConstraints = NO;
	//accImageView.frame = CGRectMake(308, 2, 12, 14);
	[self addSubview:accImageView];
	[accImageView release];
	
	separatorImage = [UIImage imageNamed:@"separator.png"];
	separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    separatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
	//separatorImageView.frame = CGRectMake(1, 18, 308, 1);
	[self addSubview:separatorImageView];
	[separatorImageView release];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(accImageView, separatorImageView);
    
    if (IPAD) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-1-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[accImageView(14)]" options:0 metrics:nil views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[accImageView(12)]-1-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[accImageView(14)]" options:0 metrics:nil views:views]];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separatorImageView]-12-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorImageView(1)]|" options:0 metrics:nil views:views]];
    
}

@end