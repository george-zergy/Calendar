//
//  DemoViewController.m
//  Calendar
//
//  Created by Vadim Kovalsky on 11/21/16.
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import "DemoViewController.h"
#import "CalendarManager.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)openCalendar:(id)sender {
    [[CalendarManager sharedInstance] openCalendarVC:self];
}

@end
