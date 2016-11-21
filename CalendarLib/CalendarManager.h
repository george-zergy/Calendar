//
//  CalendarManager.h
//  Calendar
//
//  Created by Vadim Kovalsky on 11/21/16.
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarManager : NSObject

+ (instancetype)sharedInstance;

- (void)openCalendarVC:(UIViewController *)vc;

@end
