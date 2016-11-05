//
//  UnreadMsgsViewController.m
//  SpotAlert
//
//  Created by LionKing on 9/1/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import "UnreadMsgsViewController.h"
#import "AppDelegate.h"

@interface UnreadMsgsViewController ()

@end

@implementation UnreadMsgsViewController
{
    NSString *alertMsg;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    return appDelegate.unreadMsgs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [cell.textLabel setText:appDelegate.unreadMsgs[indexPath.row]];
   
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    alertMsg = appDelegate.unreadMsgs[indexPath.row];
    
    NSString *confirmMsg = [NSString stringWithFormat:@"%@ \n Are you going to reserve now?", alertMsg];
    
    UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"SpotAlert"    message:confirmMsg
                                                               delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [notificationAlert show];
    
    // Set icon badge number to zero
    [appDelegate.unreadMsgs removeObject:alertMsg];
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"]) {
        NSString *requestUrl = [NSString stringWithFormat:@"https://www.barrysbootcamp.com%@",[appDelegate.reserveUrlDic objectForKey:alertMsg]];
        [appDelegate sendSpotReserveRequest:requestUrl];
    }
    [appDelegate.reserveUrlDic removeObjectForKey:alertMsg];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
