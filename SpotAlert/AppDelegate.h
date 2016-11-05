//
//  AppDelegate.h
//  SpotAlert
//
//  Created by LionKing on 7/24/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ReserveClassModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (assign, nonatomic) BOOL background;

@property (strong, nonatomic) dispatch_block_t expirationHandler;

@property (assign, nonatomic) BOOL jobExpired;


@property (assign, nonatomic) BOOL isRequestedSpotMonitor;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableDictionary *reservedSpots;
@property (strong, nonatomic) NSMutableDictionary *reservedClasses;
@property (strong, nonatomic) NSMutableDictionary *reserveUrlDic;
@property (strong, nonatomic) NSMutableDictionary *unreserveUrlDic;
@property (strong, nonatomic) NSMutableArray *unreadMsgs;
@property (strong, nonatomic) NSDate *lastCheckTime;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) sendSpotReserveRequest:(NSString *) reserveURL;

@end

