//
//  ViewController.h
//  SpotAlert
//
//  Created by LionKing on 7/24/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReserveClassModel.h"

#define REMINDER_CHECK_PERIOD 3600 //seconds

@interface ViewController : UIViewController
- (void) sendSpotStatusRequest;

@property (strong, nonatomic) NSString *prevPageData;
@end

