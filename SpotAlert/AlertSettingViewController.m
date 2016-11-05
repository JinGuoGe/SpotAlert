//
//  AlertSettingViewController.m
//  SpotAlert
//
//  Created by LionKing on 7/28/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import "AlertSettingViewController.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"

#import "ReserveClassModel.h"

@interface AlertSettingViewController (){
    NSMutableArray*			_cellSelected;
}


@end

@implementation AlertSettingViewController {
    NSURLConnection *_urlConnection;
    NSMutableData *_receivedData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Select spot for alert";
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
     _cellSelected = [NSMutableArray array];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSMutableArray *spots = [appDelegate.reservedSpots objectForKey:self.mornitorPageUrl];
    
   
    if (spots != nil) {
        for (int i=0; i<spots.count; i++) {
            
            if ([_spotsArray containsObject:[spots objectAtIndex:i]]) {
                NSUInteger rowIndex = [_spotsArray indexOfObject:[spots objectAtIndex:i]];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                [_cellSelected addObject:indexPath];
            }
        }

    }
    
   
}
- (void) viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate.reservedClasses objectForKey:self.mornitorPageUrl] == nil) {
        [self parseClassInfo:self.prevPageData];
    }

  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)parseClassInfo:(NSString *)pageContentString {
   
    
    ReserveClassModel *newClass = [[ReserveClassModel alloc] init];
    
   
    NSString *responseString = pageContentString;
    
    
    //Extracting  location
    NSRange range = [responseString rangeOfString:@"id=\"current-location\">"];
    if (range.location == NSNotFound) {
        NSLog(@"string was not found");
        return;
    }
    responseString =[responseString substringWithRange:NSMakeRange(range.location+range.length, responseString.length-range.location-range.length)];
    NSRange r2 = [responseString rangeOfString:@"</span>"];
    NSRange rSub = NSMakeRange(0, r2.location );
    NSString *locationStr = [responseString substringWithRange:rSub];
    NSLog(@"%@", locationStr);
    newClass.location = locationStr;
    
    //Extracting date
    range = [responseString rangeOfString:@"tab-pane active\" id=\"day"];
    if (range.location == NSNotFound) {
        NSLog(@"string was not found");
        return;
    }
    responseString =[responseString substringWithRange:NSMakeRange(range.location+range.length, responseString.length-range.location-range.length)];
    
    r2 = [responseString rangeOfString:@"\""];
    rSub = NSMakeRange(0, r2.location );
    NSString *dateStr = [responseString substringWithRange:rSub];
    NSLog(@"%@", dateStr);
    newClass.date = dateStr;
    
    // Extracting Time
    if (self.classID != nil)
    {
        range = [responseString rangeOfString:[NSString stringWithFormat:@"data-classid=\"%@\"", self.classID]];
        if (range.location != NSNotFound) {
           NSString *timeString =[responseString substringWithRange:NSMakeRange(range.location+range.length, responseString.length-range.location-range.length)];
            
            NSRange r1 = [timeString rangeOfString:@"scheduleTime\">"];
            NSRange r2 = [timeString rangeOfString:@"</span>"];
            NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
            NSString *sub = [timeString substringWithRange:rSub];
            
            r1 = [sub rangeOfString:@"<span>"];
            rSub = NSMakeRange(r1.location + r1.length, sub.length- r1.location - r1.length);
            NSString *timeStr =[sub substringWithRange:rSub];
            
            NSLog(@"%@", timeStr);
            
            newClass.time = timeStr;
            
            r1 = [responseString rangeOfString:@"<h3>"];
            r2 = [responseString rangeOfString:@"</h3>"];
            rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
            sub = [responseString substringWithRange:rSub];
            NSMutableArray *dateInfo =  [sub componentsSeparatedByString:@","];
            newClass.weekDay = dateInfo[0];
            sub = dateInfo[1];
            dateInfo = [sub componentsSeparatedByString:@" "];
            [dateInfo removeObject:@""];
            newClass.month = dateInfo[0];
            newClass.day = dateInfo[1];
        }

    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.reservedClasses setObject:newClass forKey:self.mornitorPageUrl];
        
    _urlConnection = nil;
    _receivedData = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _spotsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CustomTableViewCell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
       // NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString *item = [_spotsArray objectAtIndex:indexPath.row];
    
    if ([_cellSelected containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }

    cell.spotLabel.text = item;
    if ([item containsString:@"T-"]) {
        [cell.thumbImageView setImage:[UIImage imageNamed:@"Tread"]];
    }
    else {
        [cell.thumbImageView setImage:[UIImage imageNamed:@"Floor"]];
    }
    //cell.thumbImageView.image = [UIImage imageNamed:[thumbDic objectForKey:@"content"] ];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //the below code will allow multiple selection
    if ([_cellSelected containsObject:indexPath])
    {
        [_cellSelected removeObject:indexPath];
    }
    else
    {
        [_cellSelected addObject:indexPath];
    }
    [tableView reloadData];
}
- (IBAction)startAlert:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    NSMutableArray *spots = [appDelegate.reservedSpots objectForKey:self.mornitorPageUrl];
    if (_cellSelected.count > 0) {
        if (spots == nil) {
            spots = [NSMutableArray new];
            [appDelegate.reservedSpots setObject:spots forKey:self.mornitorPageUrl];
        }
        else {
            [spots removeAllObjects];
        }
        for (int i =0; i<_cellSelected.count; i++) {
            CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:[_cellSelected objectAtIndex:i]];
            if (![spots containsObject:cell.spotLabel.text]) {
                [spots addObject:cell.spotLabel.text];
            }
        }

    }
    else {
        if (spots!=nil) {
            [appDelegate.reservedSpots removeObjectForKey:self.mornitorPageUrl];
        }
    }
        [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)stopAlert:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSMutableArray *spots = [appDelegate.reservedSpots objectForKey:self.mornitorPageUrl];
    if (spots!=nil) {
        [appDelegate.reservedSpots removeObjectForKey:self.mornitorPageUrl];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
