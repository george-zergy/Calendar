//
//  MainViewController.m
//  CalendarDemo - Graphical Calendars Library for iOS
//
//  Copyright (c) 2014-2015 Julien Martin. All rights reserved.
//

#import "MainViewController.h"
#import "WeekViewController.h"
#import "MonthViewController.h"
#import "YearViewController.h"
#import "DayViewController.h"
#import "NSCalendar+MGCAdditions.h"
#import "WeekSettingsViewController.h"
#import "MonthSettingsViewController.h"


typedef enum : NSUInteger
{
    CalendarViewDayType = 0,
    CalendarViewWeekType = 1,
    CalendarViewMonthType = 2,
    CalendarViewYearType
} CalendarViewType;


@interface MainViewController ()<YearViewControllerDelegate, WeekViewControllerDelegate, DayViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) EKCalendarChooser *calendarChooser;
@property (nonatomic) BOOL firstTimeAppears;

@property (nonatomic) DayViewController *dayViewController;
@property (nonatomic) WeekViewController *weekViewController;
@property (nonatomic) MonthViewController *monthViewController;
@property (nonatomic) YearViewController *yearViewController;

@end


@implementation MainViewController

#pragma mark - UIViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _eventStore = [[EKEventStore alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *calID = [[NSUserDefaults standardUserDefaults]stringForKey:@"calendarIdentifier"];
    self.calendar = [NSCalendar mgc_calendarFromPreferenceString:calID];
    
    NSUInteger firstWeekday = [[NSUserDefaults standardUserDefaults]integerForKey:@"firstDay"];
    if (firstWeekday != 0) {
        self.calendar.firstWeekday = firstWeekday;
    } else {
        [[NSUserDefaults standardUserDefaults]registerDefaults:@{ @"firstDay" : @(self.calendar.firstWeekday) }];
    }
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.calendar = self.calendar;
    
    if (isiPad) {
        //NSLog(@"---------------- iPAD ------------------");
    }
    else{
        //NSLog(@"---------------- iPhone ------------------");
       // self.navigationItem.leftBarButtonItem.customView = self.currentDateLabel;
    }
	
	CalendarViewController *controller = [self controllerForViewType:CalendarViewDayType];
	[self addChildViewController:controller];
	[self.containerView addSubview:controller.view];
	controller.view.frame = self.containerView.bounds;
	[controller didMoveToParentViewController:self];
	
	self.calendarViewController = controller;
    self.firstTimeAppears = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppears) {
        NSDate *date = [self.calendar mgc_startOfWeekForDate:[NSDate date]];
        [self.calendarViewController moveToDate:date animated:NO];
        self.firstTimeAppears = NO;
    
        if ([self.eventStore calendarsForEntityType:EKEntityTypeEvent].count == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"To use calendars with Zero app you need to add at least one calendar . Please go to your iPhone Settings -> Calendar and add at least one account" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    UINavigationController *nc = (UINavigationController*)[segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"dayPlannerSettingsSegue"]) {
        WeekSettingsViewController *settingsViewController = (WeekSettingsViewController*)nc.topViewController;
        WeekViewController *weekController = (WeekViewController*)self.calendarViewController;
        settingsViewController.weekViewController = weekController;
    }
    else if ([segue.identifier isEqualToString:@"monthPlannerSettingsSegue"]) {
        MonthSettingsViewController *settingsViewController = (MonthSettingsViewController*)nc.topViewController;
        MonthViewController *monthController = (MonthViewController*)self.calendarViewController;
        settingsViewController.monthPlannerView = monthController.monthPlannerView;
    }
    
    BOOL doneButton = (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassRegular || self.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassRegular);

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UINavigationController *nc = (UINavigationController*)self.presentedViewController;
    if (nc) {
        BOOL hide = (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular);
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings:)];
        nc.topViewController.navigationItem.rightBarButtonItem = hide ? nil : doneButton;
    }
}

- (void)showPopoverForNewEvent:(EKEvent*)ev
{
    EKEventEditViewController *eventController = [EKEventEditViewController new];
    eventController.event = ev;
    eventController.eventStore = self.eventStore;
    eventController.editViewDelegate = self; // called only when event is deleted
    eventController.modalInPopover = YES;
    eventController.modalPresentationStyle = UIModalPresentationPopover;
    eventController.presentationController.delegate = self;
    
    [self showDetailViewController:eventController sender:self];
    
    UIPopoverPresentationController *popController = eventController.popoverPresentationController;
    popController.permittedArrowDirections = UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight;
    popController.delegate = self;
    popController.barButtonItem = self.navigationItem.rightBarButtonItem;
}

- (IBAction)newEvent {
    NSDate *date = [NSDate date];
    
    EKEvent *ev = [EKEvent eventWithEventStore:self.eventStore];
    ev.startDate = date;
    
    NSDateComponents *comps = [NSDateComponents new];
    comps.hour = 1;
    
    ev.endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    ev.allDay = NO;
    
    [self showPopoverForNewEvent:ev];
}

#pragma mark - Private

- (DayViewController*)dayViewController
{
    if (_dayViewController == nil) {
        _dayViewController = [[DayViewController alloc]initWithEventStore:self.eventStore];
        _dayViewController.calendar = self.calendar;
        _dayViewController.showsWeekHeaderView = YES;
        _dayViewController.delegate = self;
    }
    return _dayViewController;
}

- (WeekViewController*)weekViewController
{
    if (_weekViewController == nil) {
        _weekViewController = [[WeekViewController alloc]initWithEventStore:self.eventStore];
        _weekViewController.calendar = self.calendar;
        _weekViewController.delegate = self;
    }
    return _weekViewController;
}

- (MonthViewController*)monthViewController
{
    if (_monthViewController == nil) {
        _monthViewController = [[MonthViewController alloc]initWithEventStore:self.eventStore];
        _monthViewController.calendar = self.calendar;
        _monthViewController.delegate = self;
    }
    return _monthViewController;
}

- (YearViewController*)yearViewController
{
    if (_yearViewController == nil) {
        _yearViewController = [[YearViewController alloc]init];
        _yearViewController.calendar = self.calendar;
        _yearViewController.delegate = self;
    }
    return _yearViewController;
}

- (CalendarViewController*)controllerForViewType:(CalendarViewType)type
{
    switch (type)
    {
        case CalendarViewDayType:  return self.dayViewController;
        case CalendarViewWeekType:  return self.weekViewController;
        case CalendarViewMonthType: return self.monthViewController;
        case CalendarViewYearType:  return self.yearViewController;
    }
    return nil;
}

-(void)moveToNewController:(CalendarViewController*)newController atDate:(NSDate*)date
{
    [self.calendarViewController willMoveToParentViewController:nil];
    [self addChildViewController:newController];
    
    [self transitionFromViewController:self.calendarViewController toViewController:newController duration:.5 options:UIViewAnimationOptionCurveEaseIn animations:^
     {
         newController.view.frame = self.containerView.bounds;
         newController.view.hidden = YES;
     } completion:^(BOOL finished)
     {
         [self.calendarViewController removeFromParentViewController];
         [newController didMoveToParentViewController:self];
         self.calendarViewController = newController;
         [newController moveToDate:date animated:NO];
         newController.view.hidden = NO;
     }];
}

#pragma mark - Actions

-(IBAction)switchControllers:(UISegmentedControl*)sender
{
    NSDate *date = [self.calendarViewController centerDate];
    CalendarViewController *controller = [self controllerForViewType:sender.selectedSegmentIndex];
    [self moveToNewController:controller atDate:date];
    
}

- (IBAction)showToday:(id)sender
{
    [self.calendarViewController moveToDate:[NSDate date] animated:YES];
}

- (IBAction)nextPage:(id)sender
{
    [self.calendarViewController moveToNextPageAnimated:YES];
}

- (IBAction)previousPage:(id)sender
{
    [self.calendarViewController moveToPreviousPageAnimated:YES];
}

- (IBAction)showCalendars:(id)sender
{
    if ([self.calendarViewController respondsToSelector:@selector(visibleCalendars)]) {
        self.calendarChooser = [[EKCalendarChooser alloc]initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:self.eventStore];
        self.calendarChooser.delegate = self;
        self.calendarChooser.showsDoneButton = YES;
        self.calendarChooser.selectedCalendars = self.calendarViewController.visibleCalendars;
    }
    
    if (self.calendarChooser) {
        UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:self.calendarChooser];
        self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(calendarChooserStartEdit)];
        nc.modalPresentationStyle = UIModalPresentationPopover;
 
        [self showDetailViewController:nc sender:self];
        
        UIPopoverPresentationController *popController = nc.popoverPresentationController;
        popController.barButtonItem = (UIBarButtonItem*)sender;
    }
}

- (void)calendarChooserStartEdit
{
    self.calendarChooser.editing = YES;
    self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(calendarChooserEndEdit)];
}

- (void)calendarChooserEndEdit
{
    self.calendarChooser.editing = NO;
    self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(calendarChooserStartEdit)];
}

#pragma mark - YearViewControllerDelegate

- (void)yearViewController:(YearViewController*)controller didSelectMonthAtDate:(NSDate*)date
{
    CalendarViewController *controllerNew = [self controllerForViewType:CalendarViewMonthType];
    [self moveToNewController:controllerNew atDate:date];
    self.viewChooser.selectedSegmentIndex = CalendarViewMonthType;
}

#pragma mark - CalendarViewControllerDelegate

- (void)calendarViewController:(CalendarViewController*)controller didShowDate:(NSDate*)date
{
    if (controller.class == YearViewController.class)
        [self.dateFormatter setDateFormat:@"yyyy"];
    else
        [self.dateFormatter setDateFormat:@"MMMM yyyy"];
    
    NSString *str = [self.dateFormatter stringFromDate:date];
    self.currentDateLabel.text = str;
    //[self.currentDateLabel sizeToFit];
}

- (void)calendarViewController:(CalendarViewController*)controller didSelectEvent:(EKEvent*)event
{
    //NSLog(@"calendarViewController:didSelectEvent");
}

#pragma mark - MGCDayPlannerEKViewControllerDelegate

- (UINavigationController*)navigationControllerForEKEventViewController
{
//    if (!isiPad) {
//        return self.navigationController;
//    }
    return nil;
}


#pragma mark - EKCalendarChooserDelegate

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser*)calendarChooser
{
    if ([self.calendarViewController respondsToSelector:@selector(setVisibleCalendars:)]) {
        self.calendarViewController.visibleCalendars = calendarChooser.selectedCalendars;
    }
}

- (void)calendarChooserDidFinish:(EKCalendarChooser*)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - UIPopoverPresentationControllerDelegate

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view
{
//    CGRect cellRect;
//    if (self.createdEventDate) {
//        cellRect = [self.dayPlannerView rectForNewEventOfType:self.createdEventType atDate:self.createdEventDate];
//    }
//    else {
//        UIView *cell = self.dayPlannerView.selectedEventView;
//        cellRect = [self.dayPlannerView convertRect:cell.bounds fromView:cell];
//    }
//    CGRect visibleRect = CGRectIntersection(self.dayPlannerView.bounds, cellRect);
//    if (CGRectIsNull(visibleRect)) {
//        rect->origin.x = cellRect.origin.x;
//        rect->origin.y = fminf(cellRect.origin.y, CGRectGetMaxY(self.dayPlannerView.bounds));
//        rect->size.width = cellRect.size.width;
//    }
//    else {
//        *rect = visibleRect;
//    }
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    
}


@end
