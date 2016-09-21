//
//  SplitHeaderView.m
//  Stopwatch
//
//  Created by Steven Gentry on 6/21/16.
//  Copyright © 2016 SEGNETIX. All rights reserved.
//

#import "SplitHeaderView.h"
#import "Utilities.h"

@implementation SplitHeaderView

@synthesize lapColumn;
@synthesize timeColumn;
@synthesize splitColumn1;
@synthesize splitColumn2;
@synthesize splitColumn3;
@synthesize splitColumn4;

- (void)setup
{
    CGFloat fontSize = 15.0;
    if (IPAD) {
        fontSize = 24.0;
    }
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    lapColumn = [[UILabel alloc] init];
    lapColumn.translatesAutoresizingMaskIntoConstraints = NO;
    
    timeColumn = [[UILabel alloc] init];
    timeColumn.translatesAutoresizingMaskIntoConstraints = NO;
    
    splitColumn1 = [[UILabel alloc] init];
    splitColumn1.translatesAutoresizingMaskIntoConstraints = NO;
    
    splitColumn2 = [[UILabel alloc] init];
    splitColumn2.translatesAutoresizingMaskIntoConstraints = NO;
    
    splitColumn3 = [[UILabel alloc] init];
    splitColumn3.translatesAutoresizingMaskIntoConstraints = NO;
    
    splitColumn4 = [[UILabel alloc] init];
    splitColumn4.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(lapColumn, timeColumn, splitColumn1, splitColumn2, splitColumn3, splitColumn4);
    
    // lap column
    lapColumn.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    lapColumn.textAlignment = NSTextAlignmentRight;
    lapColumn.textColor = [UIColor blackColor];
    lapColumn.backgroundColor = [UIColor clearColor];
    lapColumn.text = [Utilities shortFormatTime:0 precision:2];
    lapColumn.hidden = NO;
    [self addSubview:lapColumn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lapColumn]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lapColumn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.12 constant:0]];
    [lapColumn release];
    
    // time column
    timeColumn.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    timeColumn.textAlignment = NSTextAlignmentRight;
    timeColumn.textColor = [UIColor blackColor];
    timeColumn.backgroundColor = [UIColor clearColor];
    timeColumn.text = [Utilities shortFormatTime:0 precision:2];
    timeColumn.hidden = NO;
    [self addSubview:timeColumn];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeColumn]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:timeColumn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.190 constant:0]];
    [timeColumn release];
    
    // split column 1
    splitColumn1.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    splitColumn1.textAlignment = NSTextAlignmentRight;
    splitColumn1.textColor = [UIColor blackColor];
    splitColumn1.backgroundColor = [UIColor clearColor];
    splitColumn1.text = [Utilities shortFormatTime:0 precision:2];
    splitColumn1.hidden = NO;
    [self addSubview:splitColumn1];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[splitColumn1]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:splitColumn1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.14 constant:0]];
    [splitColumn1 release];
    
    // split column 2
    splitColumn2.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    splitColumn2.textAlignment = NSTextAlignmentRight;
    splitColumn2.textColor = [UIColor blackColor];
    splitColumn2.backgroundColor = [UIColor clearColor];
    splitColumn2.text = [Utilities shortFormatTime:0 precision:2];
    splitColumn2.hidden = NO;
    [self addSubview:splitColumn2];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[splitColumn2]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:splitColumn2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.16 constant:0]];
    [splitColumn2 release];
    
    // split column 3
    splitColumn3.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    splitColumn3.textAlignment = NSTextAlignmentRight;
    splitColumn3.textColor = [UIColor blackColor];
    splitColumn3.backgroundColor = [UIColor clearColor];
    splitColumn3.text = [Utilities shortFormatTime:0 precision:2];
    splitColumn3.hidden = NO;
    [self addSubview:splitColumn3];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[splitColumn3]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:splitColumn3 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.16 constant:0]];
    [splitColumn3 release];
    
    // split column 4
    splitColumn4.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    splitColumn4.textAlignment = NSTextAlignmentRight;
    splitColumn4.textColor = [UIColor blackColor];
    splitColumn4.backgroundColor = [UIColor clearColor];
    splitColumn4.text = [Utilities shortFormatTime:0 precision:2];
    splitColumn4.hidden = NO;
    [self addSubview:splitColumn4];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[splitColumn4]|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:splitColumn4 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:.16 constant:0]];
    [splitColumn4 release];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lapColumn]-2-[timeColumn]-2-[splitColumn1]-2-[splitColumn2]-2-[splitColumn3]-2-[splitColumn4]" options:0 metrics:nil views:views]];
}

- (void)dealloc
{
    /*
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
    */
    
    [super dealloc];
}

- (void)setTextWithArray:(NSMutableArray*)textArray;
{
    lapColumn.text = @"";
    timeColumn.text = @"";
    splitColumn1.text = @"";
    splitColumn2.text = @"";
    splitColumn3.text = @"";
    splitColumn4.text = @"";
    
    int count = 0;
    for (NSString *text in textArray) {
        switch (count) {
            case 0: lapColumn.text = text;      break;
            case 1: timeColumn.text = text;     break;
            case 2: splitColumn1.text = text;   break;
            case 3: splitColumn2.text = text;   break;
            case 4: splitColumn3.text = text;   break;
            case 5: splitColumn4.text = text;   break;
            default: break;
        }
        count++;
    }
}

@end
