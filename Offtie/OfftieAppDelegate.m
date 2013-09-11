//
//  OfftieAppDelegate.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 8/26/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "OfftieAppDelegate.h"

@implementation OfftieAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id) navigationController.topViewController;
    }
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:2];
    [comps setMonth:12];
    [comps setYear:2012];
    [comps setHour:17];
    [comps setMinute:20];
    [comps setSecond:00];
   // NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60];
  //  [self scheduleAlarmForDate:date];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*-(void) scheduleAlarmForDate:(NSDate *) date {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    if (oldNotifications.count > 0) {
        [app cancelAllLocalNotifications];
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        notification.fireDate = date;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = 0;
        notification.alertBody = @"Open me to refresh your timeline";
        notification.applicationIconBadgeNumber = 1;
        [app scheduleLocalNotification:notification];
    }
}*/

@end
