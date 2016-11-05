//
//  AppDelegate.m
//  SpotAlert
//
//  Created by LionKing on 7/24/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UIAlertView+Blocks.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    self.reservedSpots = [[NSMutableDictionary alloc] init];
    self.reservedClasses = [[NSMutableDictionary alloc] init];
    self.reserveUrlDic = [[NSMutableDictionary alloc] init];
    self.unreserveUrlDic = [[NSMutableDictionary alloc] init];
    self.unreadMsgs = [NSMutableArray new];
    self.lastCheckTime = NULL;
    self.isRequestedSpotMonitor = false;
    
    NSLog(@"Finish launch");
    
    UIApplication* app = [UIApplication sharedApplication];
    
    self.expirationHandler = ^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        self.bgTask = [app beginBackgroundTaskWithExpirationHandler:self.expirationHandler];
        NSLog(@"Expired");
        self.jobExpired = YES;
        while(self.jobExpired) {
            // spin while we wait for the task to actually end.
            [NSThread sleepForTimeInterval:1];
        }
        // Restart the background task so we can run forever.
        [self startBackgroundTask];
    };
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:self.expirationHandler];

    
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"Cookies"];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        NSLog(@"Recived notification in foreground");
        
        if ([notification.alertBody rangeOfString:@"cancel this spot"].location == NSNotFound) {
            NSString *confirmMsg = [NSString stringWithFormat:@"%@ \n Are you going to reserve now?", notification.alertBody];
            RIButtonItem *noButton = [RIButtonItem itemWithLabel:@"No" action:^{
                [self.reserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            RIButtonItem *yesButton = [RIButtonItem itemWithLabel:@"Yes" action:^{
                NSString *requestUrl = [NSString stringWithFormat:@"https://www.barrysbootcamp.com%@",[self.reserveUrlDic objectForKey:notification.alertBody]];
                [self sendSpotReserveRequest:requestUrl];
                [self.reserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            
            UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"SpotAlert" message:confirmMsg cancelButtonItem:noButton otherButtonItems:yesButton, nil];
            [notificationAlert show];
            
            // Set icon badge number to zero
            [self.unreadMsgs removeObject:notification.alertBody];
            application.applicationIconBadgeNumber = self.unreadMsgs.count;
        }
        else
        {
            RIButtonItem *noButton = [RIButtonItem itemWithLabel:@"No" action:^{
                [self.unreserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            RIButtonItem *yesButton = [RIButtonItem itemWithLabel:@"Yes" action:^{
                NSString *requestUrl = [NSString stringWithFormat:@"https://www.barrysbootcamp.com%@",[self.unreserveUrlDic objectForKey:notification.alertBody]];
                [self sendSpotReserveRequest:requestUrl];
                [self.unreserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            
            UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"SpotAlert" message:notification.alertBody cancelButtonItem:noButton otherButtonItems:yesButton, nil];
            [notificationAlert show];

        }
        
    }
    
    else if (state == UIApplicationStateInactive) {
        NSLog(@"Recived notification in Inactive");
        
        if ([notification.alertBody rangeOfString:@"cancel this spot"].location == NSNotFound)
        {
            NSString *confirmMsg = [NSString stringWithFormat:@"%@ \n Are you going to reserve now?", notification.alertBody];
            RIButtonItem *noButton = [RIButtonItem itemWithLabel:@"No" action:^{
                [self.reserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            RIButtonItem *yesButton = [RIButtonItem itemWithLabel:@"Yes" action:^{
                NSString *requestUrl = [NSString stringWithFormat:@"https://www.barrysbootcamp.com%@",[self.reserveUrlDic objectForKey:notification.alertBody]];
                [self sendSpotReserveRequest:requestUrl];
                [self.reserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            
            UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"SpotAlert" message:confirmMsg cancelButtonItem:noButton otherButtonItems:yesButton, nil];
            [notificationAlert show];
            
            // Set icon badge number to zero
            [self.unreadMsgs removeObject:notification.alertBody];
            application.applicationIconBadgeNumber = self.unreadMsgs.count;
        }
        else
        {
            RIButtonItem *noButton = [RIButtonItem itemWithLabel:@"No" action:^{
                [self.unreserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            RIButtonItem *yesButton = [RIButtonItem itemWithLabel:@"Yes" action:^{
                NSString *requestUrl = [NSString stringWithFormat:@"https://www.barrysbootcamp.com%@",[self.unreserveUrlDic objectForKey:notification.alertBody]];
                [self sendSpotReserveRequest:requestUrl];
                [self.unreserveUrlDic removeObjectForKey:notification.alertBody];
            }];
            
            
            UIAlertView *notificationAlert = [[UIAlertView alloc]initWithTitle:@"SpotAlert" message:notification.alertBody cancelButtonItem:noButton otherButtonItems:yesButton, nil];
            [notificationAlert show];

            
        }

    }
   /* else if (state == UIApplicationStateBackground) {
        NSLog(@"Recived notification in background");
    } */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Entered background");
    [self monitorBatteryStateInBackground];
}
- (void)monitorBatteryStateInBackground
{
    
    NSLog(@"Monitoring battery state");
    self.background = YES;
    
    [self startBackgroundTask];
}
- (void) sendSpotReserveRequest:(NSString *) reserveURL {
   
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:reserveURL]];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@".barrysbootcamp.com"]];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    [[NSURLConnection alloc]initWithRequest:request delegate:nil];
}
- (void)startBackgroundTask
{
    NSLog(@"Restarting task");
    // Start the long-running task.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
        // set a flag that the job expired and use that to exit the while loop and end the task.
        while(self.background && !self.jobExpired)
        {
            
            [NSThread sleepForTimeInterval:1];
            UINavigationController *navigationController = [self.window rootViewController];
            for (UIViewController *viewController in navigationController.viewControllers ) {
                if ([viewController isKindOfClass:[ViewController class]]) {
                    if (self.reservedSpots.count > 0) {
                        id mainController = (ViewController *) viewController;
                        [mainController sendSpotStatusRequest];
                    }
                }
            }
            
            /*id mainController = (ViewController*)  self.window.rootViewController;
            if ([mainController isKindOfClass:[ViewController class]]) {
                if (self.reservedSpots.count > 0) {
                    [mainController sendSpotStatusRequest];
                }
            }*/
           
        }
        
        self.jobExpired = NO;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"App is active");
    self.background = NO;

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"Cookies"];
    
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bigcity.SpotAlert" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SpotAlert" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SpotAlert.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
