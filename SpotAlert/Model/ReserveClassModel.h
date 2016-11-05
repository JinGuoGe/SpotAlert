//
//  ReserveClassModel.h
//  SpotAlert
//
//  Created by LionKing on 8/16/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReserveClassModel : NSObject

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *weekDay;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *day;

@end
