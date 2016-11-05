//
//  UnreadMsgsViewController.h
//  SpotAlert
//
//  Created by LionKing on 9/1/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadMsgsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
