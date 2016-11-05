//
//  AlertSettingViewController.h
//  SpotAlert
//
//  Created by LionKing on 7/28/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *spotsArray;

@property (weak, nonatomic) NSURL *mornitorPageUrl;
@property (strong, nonatomic) NSString *classID;
@property (weak, nonatomic) NSString *prevPageData;
@end
