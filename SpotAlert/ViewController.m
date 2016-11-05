//
//  ViewController.m
//  SpotAlert
//
//  Created by LionKing on 7/24/16.
//  Copyright © 2016 bigcity. All rights reserved.
//

#import "ViewController.h"
#import "AlertSettingViewController.h"
#import "AppDelegate.h"

@interface ViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *monitorBtnItem;

@property (assign, nonatomic) BOOL isMornitoring;

- (void)loadRequestFromString:(NSString*)urlString;
- (void)updateButtons;
@end

@implementation ViewController {
    NSURLConnection *_urlConnection;
    NSMutableData *_receivedData;
    NSMutableArray *_monitorSpots;
    int classIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Test code
    /* AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UILocalNotification *notification = [[UILocalNotification alloc] init];
     [appDelegate.unreadMsgs addObject:@"test alert"];
    NSDate * secs = [[NSDate alloc] initWithTimeIntervalSinceNow:15];
    notification.alertBody = @"test alert";
    notification.alertAction = @"View";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.fireDate = secs;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];*/
    
    _monitorSpots = [NSMutableArray new];
    _isMornitoring = false;

    classIndex = 0;
    
    [self setNewMessageCount:0];
    
    NSAssert([self.webView isKindOfClass:[UIWebView class]], @"You webView outlet is not correctly connected.");
    NSAssert(self.back, @"Your back button outlet is not correctly connected");
    NSAssert(self.refresh, @"Your refresh button outlet is not correctly connected");
    NSAssert(self.forward, @"Your forward button outlet is not correctly connected");
    NSAssert((self.back.target == self.webView) && (self.back.action = @selector(goBack)), @"Your back button action is not connected to goBack.");
    
    NSAssert((self.refresh  .target == self.webView) && (self.refresh.action = @selector(reload)), @"Your refresh button action is not connected to reload.");
    NSAssert((self.forward.target == self.webView) && (self.forward.action = @selector(goForward)), @"Your forward button action is not connected to goForward.");
    NSAssert(self.webView.scalesPageToFit, @"You forgot to check 'Scales Page to Fit' for your web view.");
    // Do any additional setup after loading the view, typically from a nib.
    self.webView.delegate = self;
    NSString* useragent = @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36";
    
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [self loadRequestFromString:@"https://www.barrysbootcamp.com"];
}
- (void)viewDidAppear:(BOOL)animated {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [self setNewMessageCount:appDelegate.unreadMsgs.count];
    if (appDelegate.reservedSpots.count > 0) {
        if (_isMornitoring == NO) {
             self.title = @"Monitoring...";
            _isMornitoring = YES;
            [self sendSpotStatusRequest];
        }
    }
    else {
        self.title = @"Select spots to monitor";
        _isMornitoring = NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setNewMessageCount:(NSUInteger)nCount
{
    UIButton *badgeBtn;
    UIButton *messageBtn;

    // Initialize NKNumberBadgeView...
    NSString *strCount = [NSString stringWithFormat:@"%lu", (unsigned long)nCount];
    badgeBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
    badgeBtn.frame =CGRectMake(20, 00, 20,20);
    [badgeBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [badgeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [badgeBtn setBackgroundImage:[UIImage imageNamed:@"redCircle"] forState:UIControlStateNormal];
    [badgeBtn setTitle:strCount forState:UIControlStateNormal];
    // Allocate UIButton
    messageBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
    messageBtn.frame = CGRectMake(0, 0, 48, 48);
    //btn.layer.cornerRadius = 8;
    [messageBtn setImage:[UIImage imageNamed:@"newMessage"] forState:UIControlStateNormal];
    [messageBtn addTarget:self action:@selector(unreadMsgsViewTouched:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setBackgroundColor:[UIColor clearColor]];
    //[btn setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.2]];
    //[btn setFont:[UIFont systemFontOfSize:13]];
    if (nCount>0) {
        [messageBtn addSubview:badgeBtn]; //Add badge as a subview on UIButton
    }
    
    
    // Initialize UIBarbuttonitem...
    UIBarButtonItem *proe = [[UIBarButtonItem alloc] initWithCustomView:messageBtn];
    self.navigationItem.rightBarButtonItem = proe;

}
-(BOOL) doAnalyzingReminderResponse:(NSData *) responseData currentTime:(NSDate *) currentTime
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    while (true) {
        NSRange rangeStart = [responseString rangeOfString:@"<tr class=\"data \">"];
        
        if (rangeStart.location == NSNotFound ) {
            NSLog(@"Not reserved yet");
            break;
        } else {
            NSLog(@"start position %lu", (unsigned long)rangeStart.location);
        }

        NSString *subString = [responseString substringWithRange:NSMakeRange(rangeStart.location, responseString.length - rangeStart.location)];
        NSRange rangeEnd = [subString rangeOfString:@"</tr>"];
        
        if (rangeEnd.location == NSNotFound ) {
            NSLog(@"Not reserved yet");
            break;
        } else {
            NSLog(@"end position %lu", (unsigned long)rangeEnd.location);
        }

        rangeEnd.location = rangeEnd.location + rangeStart.location;
        
        
        NSRange rangeSub = NSMakeRange(rangeStart.location + rangeStart.length, rangeEnd.location - rangeStart.location - rangeStart.length);
        NSString *itemString = [responseString substringWithRange:rangeSub];
        NSRange tdStart[8];
        NSRange tdEnd[8];
        
        NSString *spotDate = NULL;
        NSString *spotName = NULL;
        NSString *spotLocation = NULL;
        NSString *spotCancelUrl = NULL;
        
        for (int i=0;i < 8;i++)
        {
            if (i==3 || i == 5)
            {
                tdStart[i] = [itemString rangeOfString:@"<td class=\"no-xs-mobile\">"];
            }
            else
            {
                tdStart[i] = [itemString rangeOfString:@"<td>"];
            }
            
            tdEnd[i] = [itemString rangeOfString:@"</td>"];
            NSRange tdSub = NSMakeRange(tdStart[i].location + tdStart[i].length, tdEnd[i].location - tdStart[i].location - tdStart[i].length);
            NSString *tdString = [itemString substringWithRange:tdSub];
            itemString = [itemString substringWithRange:NSMakeRange(tdEnd[i].location+tdEnd[i].length, itemString.length-tdEnd[i].location-tdEnd[i].length)];
            
            if (i == 1)
            {
                //In case date td
                // Instantiate a NSDateFormatter
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                // Set the dateFormatter format
                [dateFormatter setDateFormat:@"E MM/dd/yy - HH:mm a"];
                NSDate *reservedDate = [dateFormatter dateFromString:tdString];
                
                NSTimeInterval secondsBetween = [reservedDate timeIntervalSinceDate:currentTime];
                int minBetween = secondsBetween / 60;
                if (13*60 <= minBetween && minBetween <= 14*60)
                {
                    spotDate = tdString;
                }
                else
                {
                    break;
                }
            }
            else if (i == 2)
            {
                spotName = tdString;
            }
            else if (i == 5)
            {
                spotLocation = tdString;
            }
            else if ( i== 7)
            {
                NSRange urlStart;
                NSRange urlEnd;
                
                urlStart = [tdString rangeOfString:@"/reserve/index.cfm?"];
                urlEnd = [tdString rangeOfString:@"')\""];
                
                NSRange urlRange = NSMakeRange(urlStart.location, urlEnd.location - urlStart.location);
                spotCancelUrl = [tdString substringWithRange:urlRange];
                
                NSLog(@"spotCancelUrl is %@", spotCancelUrl);
            }
            NSLog(@"tdString is %@", tdString);
        }
        
        responseString = [responseString substringWithRange:NSMakeRange(rangeEnd.location+rangeEnd.length, responseString.length-rangeEnd.location-rangeEnd.length)];
        NSLog(@"spotName is %@", spotName);
        if (spotName != NULL) {
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            
            NSString *alarmMsg = [NSString stringWithFormat:@" %@, %@, %@\n Do you want to cancel this spot?",spotName, spotLocation, spotDate];
            [appDelegate.unreserveUrlDic setObject:spotCancelUrl forKey:alarmMsg];
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            NSDate * secs = [[NSDate alloc] initWithTimeIntervalSinceNow:3];
            notification.alertBody = alarmMsg;
            notification.alertAction = @"View";
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.fireDate = secs;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }

    return YES;
}
-(void) doAnalyzingMonitorResponse:(NSData *) responseData
{
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    //[_webView loadData:_receivedData MIMEType:@"text/html" textEncodingName:@"@utf-8" baseURL:nil];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *webData = responseString;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //NSLog(@"%@",responseString);
    
    [_monitorSpots removeAllObjects];
    while (true) {
        NSRange range = [responseString rangeOfString:@"Enrolled"];
        if (range.location == NSNotFound) {
            NSLog(@"string was not found");
            break;
        } else {
            NSLog(@"position %lu", (unsigned long)range.location);
        }
        
        responseString =[responseString substringWithRange:NSMakeRange(range.location+range.length, responseString.length-range.location-range.length)];
        
        NSRange r1 = [responseString rangeOfString:@"<span>"];
        NSRange r2 = [responseString rangeOfString:@"</span>"];
        NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
        NSString *sub = [responseString substringWithRange:rSub];
        NSLog(@"%@", sub);
        [_monitorSpots addObject:sub];
        
        responseString =[responseString substringWithRange:NSMakeRange(r2.location+r2.length, responseString.length-r2.location-r2.length)];
    }
   
    NSArray *keys = [appDelegate.reservedSpots allKeys];
    NSMutableArray *spots = [appDelegate.reservedSpots objectForKey:keys[classIndex]];
    
    for (int i=0; i<spots.count; i++) {
        if ([_monitorSpots containsObject:[spots objectAtIndex:i]]) {
            NSLog(@"disabled - %@", [spots objectAtIndex:i]);
        }
        else {
            NSLog(@"Enabled - %@", [spots objectAtIndex:i]);
            
            NSString* strReserveURL = [self getReserveUrl:[spots objectAtIndex:i] webPageData:webData];
            if (strReserveURL != NULL)
            {
                NSLog(@"Reserve URL - %@", strReserveURL);
                
                
                ReserveClassModel *classModel = [appDelegate.reservedClasses objectForKey:keys[classIndex]];
                //Spot T24 is available on Tuesday, March 12th at 11am in Noho
                NSString *alarmMsg = [NSString stringWithFormat:@"Spot %@ is available on %@, %@ %@th at %@ in %@",[spots objectAtIndex:i], classModel.weekDay, classModel.month, classModel.day, classModel.time, classModel.location];
                [appDelegate.reserveUrlDic setObject:strReserveURL forKey:alarmMsg];
                [appDelegate.unreadMsgs addObject:alarmMsg];
                
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                NSDate * secs = [[NSDate alloc] initWithTimeIntervalSinceNow:3];
                notification.alertBody = alarmMsg;
                notification.alertAction = @"View";
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.applicationIconBadgeNumber = appDelegate.unreadMsgs.count;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.fireDate = secs;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                [spots removeObjectAtIndex:i];
            }
            
        }
        if (spots.count==0) {
            [appDelegate.reservedSpots removeObjectForKey:keys[classIndex]];
        }
    }
   
}
- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}
- (void) checkSpotReminder {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSDate *currentCheckTime = [NSDate date];
    NSTimeInterval secondsBetween = REMINDER_CHECK_PERIOD;
    if (appDelegate.lastCheckTime != NULL) {
        secondsBetween = [currentCheckTime timeIntervalSinceDate:appDelegate.lastCheckTime];
    }
   
    if (secondsBetween >= REMINDER_CHECK_PERIOD) {
        
      
        NSString *accountClassURL = [NSString stringWithFormat:@"%@", @"http://www.barrysbootcamp.com/reserve/index.cfm?action=Account.classes"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:accountClassURL]];
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@".barrysbootcamp.com"]];
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        [request setAllHTTPHeaderFields:headers];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if (data){
                //do something with data
                NSLog(@"checking reminder spots %@",accountClassURL);
                
                [self doAnalyzingReminderResponse:data currentTime:currentCheckTime];
                
                if (!appDelegate.background)
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (REMINDER_CHECK_PERIOD +10) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        [self checkSpotReminder];
                    });
                }
               
            }
            else if (error)
            {
                NSLog(@"%@",error);
                if (!appDelegate.background)
                    [self checkSpotReminder];
            }
            
        }];

        appDelegate.lastCheckTime = currentCheckTime;
    }
}
- (void) sendSpotStatusRequest {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.isRequestedSpotMonitor == false && _isMornitoring == YES)
    {
        int nCount = appDelegate.reservedSpots.count;
        NSArray *keys = [appDelegate.reservedSpots allKeys];
        if (nCount > 0) {
            NSString *currentURL = [NSString stringWithFormat:@"%@", keys[classIndex]];
            NSLog(@"sending request to %@",currentURL);
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:currentURL]];
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@".barrysbootcamp.com"]];
            NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            [request setAllHTTPHeaderFields:headers];
             appDelegate.isRequestedSpotMonitor = true;
            
            //_urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                if (data){
                    //do something with data
                    NSLog(@"received response from %@",currentURL);
                    [self doAnalyzingMonitorResponse:data];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        NSUInteger nCount = appDelegate.reservedSpots.count;
                        classIndex = (classIndex + 1) % nCount;
                        appDelegate.isRequestedSpotMonitor = false;
                        if (!appDelegate.background)
                            [self sendSpotStatusRequest];
                        
                    });
                }
                else if (error)
                {
                    NSLog(@"%@",error);
                    appDelegate.isRequestedSpotMonitor = false;
                    if (!appDelegate.background)
                        [self sendSpotStatusRequest];
                }
                
            }];
            
        }

    }
    
}
- (void) sendSpotStatusRequestToCurrentpage {
    
    NSString *currentURL = self.webView.request.URL.absoluteString;
    NSLog(@"sending request to %@",currentURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:currentURL]];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@".barrysbootcamp.com"]];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];

    _urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(_urlConnection) {
        _receivedData = [[NSMutableData alloc] init];
    }

}
- (IBAction)openMornitorSetting:(id)sender {
    [self checkSpotReminder];
    _isMornitoring = false;
    self.monitorBtnItem.enabled = false;
    [self sendSpotStatusRequestToCurrentpage];
}
- (NSString *) getReserveUrl:(NSString *) spotName webPageData:(NSString *) webData {
    NSRange range = [webData rangeOfString:[NSString stringWithFormat:@"<span>%@</span>", spotName]];
    if (range.location != NSNotFound)
    {
        NSString * webSubString =[webData substringWithRange:NSMakeRange(0, range.location-1)];
        
        range = [webSubString rangeOfString:@"<a href=\"" options:NSBackwardsSearch];
        webSubString =[webSubString substringWithRange:NSMakeRange(range.location+range.length, webSubString.length-range.location-range.length)];
        
        range = [webSubString rangeOfString:@"\""];
        webSubString =[webSubString substringWithRange:NSMakeRange(0, range.location)];
        
        return  [webSubString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    }
    return NULL;
}
#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failure.");
    _receivedData = nil;
    _urlConnection = nil;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
 
}
#pragma mark - NSURLConnectionDataDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
    //[_webView loadData:_receivedData MIMEType:@"text/html" textEncodingName:@"@utf-8" baseURL:nil];
    NSString *responseString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    NSString *webData = responseString;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    //NSLog(@"%@",responseString);
  
    [_monitorSpots removeAllObjects];
    while (true) {
        NSRange range = [responseString rangeOfString:@"Enrolled"];
        if (range.location == NSNotFound) {
            NSLog(@"string was not found");
            break;
        } else {
            NSLog(@"position %lu", (unsigned long)range.location);
        }
        
        responseString =[responseString substringWithRange:NSMakeRange(range.location+range.length, responseString.length-range.location-range.length)];
        
        NSRange r1 = [responseString rangeOfString:@"<span>"];
        NSRange r2 = [responseString rangeOfString:@"</span>"];
        NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
        NSString *sub = [responseString substringWithRange:rSub];
        NSLog(@"%@", sub);
        [_monitorSpots addObject:sub];
        
        responseString =[responseString substringWithRange:NSMakeRange(r2.location+r2.length, responseString.length-r2.location-r2.length)];
    }
   
    [self performSegueWithIdentifier:@"MainViewToAlertSettingView" sender:self];
    
    _urlConnection = nil;
    _receivedData = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MainViewToAlertSettingView"])
    {
        self.monitorBtnItem.enabled = true;
        AlertSettingViewController *destViewController = segue.destinationViewController;
        destViewController.spotsArray = _monitorSpots;
        destViewController.prevPageData = self.prevPageData;
        destViewController.mornitorPageUrl = self.webView.request.URL;
        
        if ([self.webView.request.URL.absoluteString containsString:@"Reserve.chooseSpot&classid="]) {
            NSString *classUrlString = self.webView.request.URL.absoluteString;
            NSRange r1 = [classUrlString rangeOfString:@"Reserve.chooseSpot&classid="];
           
            NSRange rSub = NSMakeRange(r1.location + r1.length, classUrlString.length - r1.location - r1.length);
            NSString *classIdString = [classUrlString substringWithRange:rSub];
            destViewController.classID = classIdString;
            NSLog(@"classIdString - %@", classIdString );
        }
        
    }
}
#pragma mark - Updating the UI
- (void)updateButtons
{
    //NSLog(@"%s loading = %@", __PRETTY_FUNCTION__, self.webView.loading ? @"YES" : @"NO");
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    
}
- (IBAction)unreadMsgsViewTouched:(id)sender {
    [self performSegueWithIdentifier:@"MainViewToMsgsView" sender:self];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString containsString:@"Reserve.chooseSpot"]  ) {
        if (![self.webView.request.URL.absoluteString containsString:@"Reserve.chooseSpot"]) {
            NSLog(@"URL-%@", request.URL.absoluteString);
            self.prevPageData = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        }
        
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   // NSLog(@"%s", __PRETTY_FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

@end

