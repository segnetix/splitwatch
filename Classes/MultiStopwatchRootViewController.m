//
//  MultiStopwatchRootViewController.m
//  Stopwatch
//
//  Created by Steven Gentry on 11/20/09.
//  Copyright 2009 segnetix.com. All rights reserved.
//

#import "MultiStopwatchRootViewController.h"
#import "MultiStopwatchViewController.h"
#import "MultiStopwatchFlipsideViewController.h"
#import "StopwatchAppDelegate.h"

@implementation MultiStopwatchRootViewController

@synthesize settingsViewController;
@synthesize setupButton;
@synthesize flipsideNavigationBar;
@synthesize mainViewController;
@synthesize flipsideViewController;
@synthesize stateDataFilePath;
@synthesize appDelegate;

- (id)initWithSettingsViewController:(SettingsViewController *)theSettingsVC;
{
    if (self = [super init])
    {
        settingsViewController = theSettingsVC;
        stateDataFilePath = @"";
        
        appDelegate = (StopwatchAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

- (void)dealloc
{
    [setupButton release];
    [flipsideNavigationBar release];
    [mainViewController release];
    [flipsideViewController release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    // init interface elements
    setupButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    setupButton.translatesAutoresizingMaskIntoConstraints = NO;
    setupButton.tag = @"setupButton";
    
    MultiStopwatchViewController *viewController = [[MultiStopwatchViewController alloc] initWithSettingsViewController:settingsViewController];
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // AutoLayout setup
    UIView* multiStopwatchMainView = viewController.view;
    multiStopwatchMainView.tag = @"multiStopwatchMainView";
    NSDictionary *views = NSDictionaryOfVariableBindings(setupButton, multiStopwatchMainView);
    
    // setupButton
    //setupButton.frame = CGRectMake(24, 58, 48, 28);
    [setupButton addTarget:self action:@selector(toggleView) forControlEvents:UIControlEventTouchUpInside];
    [setupButton setTitle:@"Setup" forState:UIControlStateNormal];
    [setupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [setupButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [setupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    setupButton.layer.borderColor = [UIColor blackColor].CGColor;
    setupButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:12];
    setupButton.layer.borderWidth = 1.0f;
    setupButton.layer.cornerRadius = 4.0f;
    [self.view addSubview:setupButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[setupButton(48)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-58-[setupButton(28)]" options:0 metrics:nil views:views]];
    
    // multiStopwatchMainView
    self.mainViewController = viewController;
    
    //multiStopwatchMainView.frame = CGRectMake(0, 0, 300, 400);
    [self.view insertSubview:mainViewController.view belowSubview:setupButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[multiStopwatchMainView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[multiStopwatchMainView]|" options:0 metrics:nil views:views]];
    [viewController release];
    
    if (stateDataFilePath.length > 0)
    {
        [mainViewController loadStateFromFile:stateDataFilePath];
        stateDataFilePath = @"";
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    // only reset the interval units if the time is in a reset state
    [mainViewController resetIntervalUnitsIfWatchIsReset];
    
    // but we can change the start and lap button behaviors
    [mainViewController setWatchButtonBehavior];
    
    [super viewWillAppear:animated];
}

- (void)loadFlipsideViewController
{
    MultiStopwatchFlipsideViewController *viewController = [[MultiStopwatchFlipsideViewController alloc] initWithMainViewController:mainViewController];
    
    self.flipsideViewController = viewController;
    self.mainViewController.flipsideViewController = viewController;
    [viewController release];
    
    // Set up the navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    aNavigationBar.barStyle = UIBarStyleBlackOpaque;
    self.flipsideNavigationBar = aNavigationBar;
    [aNavigationBar release];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleView)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Multiwatch Settings"];
    navigationItem.rightBarButtonItem = buttonItem;
    [flipsideNavigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem release];
    [buttonItem release];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (IBAction)toggleView
{
    /*
     This method is called when the info or Done button is pressed.
     It flips the displayed view from the main view to the flipside view and vice-versa.
     */
    
    if (mainViewController.bTimerRunning)
    {
        return;
    }
    
    [appDelegate playClickSound];
    
    if (flipsideViewController == nil)
    {
        [self loadFlipsideViewController];
    }
    
    UIView *mainView = mainViewController.view;
    UIView *flipsideView = flipsideViewController.view;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
    
    if ([mainView superview] != nil)
    {
        // FlipsideView
        [flipsideViewController viewWillAppear:YES];
        [mainViewController viewWillDisappear:YES];
        [mainView removeFromSuperview];
        [setupButton removeFromSuperview];
        [self.view addSubview:flipsideView];
        [self.view insertSubview:flipsideNavigationBar aboveSubview:flipsideView];
        [mainViewController viewDidDisappear:YES];
        [flipsideViewController viewDidAppear:YES];
        
    }
    else
    {
        // MultiStopwatchMainView
        [mainViewController flipsideReturned];
        [mainViewController viewWillAppear:YES];
        [flipsideViewController viewWillDisappear:YES];
        [flipsideView removeFromSuperview];
        [flipsideNavigationBar removeFromSuperview];
        [self.view addSubview:mainView];
        [self.view insertSubview:setupButton aboveSubview:mainViewController.view];
        [flipsideViewController viewDidDisappear:YES];
        [mainViewController viewDidAppear:YES];
        [mainViewController resetMultiwatch];
    }
    
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    
    // Release anything that's not essential, such as cached data
}

- (void)addAllEventsToDatabase
{
    [mainViewController addAllEventsToDatabase];
}

- (void)saveStateToFile:(NSString *)rootFilePath
{
    [mainViewController saveStateToFile:rootFilePath];
}

- (void)loadStateFromFile:(NSString *)rootFilePath
{
    if (mainViewController != nil)
    {
        [mainViewController loadStateFromFile:rootFilePath];
    }
    else
    {
        // mainViewController has not loaded yet
        // so save the state path for later access
        self.stateDataFilePath = rootFilePath;
    }
}

@end
