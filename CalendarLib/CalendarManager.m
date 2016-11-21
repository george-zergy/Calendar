//
//  CalendarManager.m
//  Calendar
//
//  Created by Vadim Kovalsky on 11/21/16.
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import "CalendarManager.h"

@implementation CalendarManager

+ (instancetype)sharedInstance {
    static CalendarManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)openCalendarVC:(UIViewController *)vc {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"main-iPad" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainViewController"];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [vc presentViewController:viewController animated:YES completion:nil];
    } else {
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"main-iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"MainNav"];
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [vc presentViewController:viewController animated:YES completion:nil];
    }
}

@end
