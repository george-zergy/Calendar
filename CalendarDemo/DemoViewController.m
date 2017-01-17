//
//  DemoViewController.m
//  Calendar
//
//  Created by Vadim Kovalsky on 11/21/16.
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import "DemoViewController.h"

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
    [self openCalendarVC:self];
}


- (void)openCalendarVC:(UIViewController *)vc {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"main-iPad" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainNav"];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [vc presentViewController:viewController animated:YES completion:nil];
    } else {
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"main-iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainNav"];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [vc presentViewController:viewController animated:YES completion:nil];
    }
}


@end
