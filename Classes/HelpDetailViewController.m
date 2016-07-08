//
//  HelpDetailViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 2/22/10.
//  Copyright 2010 segnetix.com. All rights reserved.
//

#import "HelpDetailViewController.h"
#import "StopwatchAppDelegate.h"

@implementation HelpDetailViewController

@synthesize helpMode;
@synthesize appDelegate;

- (id)initWithMode:(NSInteger)mode
{
	if (self = [super init])
	{
		helpMode = mode;
		
		appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
	
    return self;
}

- (void)dealloc
{	
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// setup the helpTextView
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.tag = @"webView";

    UIImage *separatorImage = [UIImage imageNamed:@"separator_dark_gray.png"];
    UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
    bottomSeparatorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(webView, bottomSeparatorImageView);
    
	NSString *filePath = nil;
	
	switch (helpMode)
	{
		case kSplitwatchMode:
			filePath = [[NSBundle mainBundle] pathForResource:@"Help_Splitwatch" ofType:@"html"];
            self.navigationItem.title = @"Splitwatch";
			break;
		case kMultiwatchMode:
			filePath = [[NSBundle mainBundle] pathForResource:@"Help_Multiwatch" ofType:@"html"];
            self.navigationItem.title = @"Multiwatch";
			break;
		case kHistoryMode:
			filePath = [[NSBundle mainBundle] pathForResource:@"Help_History" ofType:@"html"];
            self.navigationItem.title = @"History";
			break;
		case kSettingsMode:
			filePath = [[NSBundle mainBundle] pathForResource:@"Help_Settings" ofType:@"html"];
            self.navigationItem.title = @"Settings";
			break;
		default:
			break;
	}
	
	if (filePath)
	{
		NSStringEncoding encoding;
		NSError* error;
		
		NSString* htmlString = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
		if (htmlString)
		{
			[webView loadHTMLString:htmlString baseURL:baseURL];
		}
	}
    
	
	[self.view addSubview:webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:views]];
	[webView release];
    
    // tab control separator
    [self.view addSubview:bottomSeparatorImageView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomSeparatorImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomSeparatorImageView(1)]-49-|" options:0 metrics:nil views:views]];
    [bottomSeparatorImageView release];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}

@end

