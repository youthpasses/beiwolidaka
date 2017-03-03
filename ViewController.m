//
//  ViewController.m
//  daka
//
//  Created by MaKai on 11/22/16.
//  Copyright © 2016 youthpasses. All rights reserved.
//

#import "ViewController.h"
//#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface ViewController (){
    
    CGSize size;
    UIWebView *loginWebView;
    NSString *token;
    NSString *name;
    
    //登录成功
    UILabel *topLabel1;
    UILabel *topLabel2;
    UILabel *topLabel3;
    UILabel *statusLabel;
    UIButton *checkinBtn;
    UIButton *checkoutBtn;
    UIButton *logoutBtn;
    UIButton *historyBtn;
    UIButton *closeHistoryBtn;
    
    //历史
    UITableView *historyTableView;
    NSMutableArray *recordArray;
    
    //日期
    NSString *year;
    NSString *month;
    NSString *day;
    NSString *week;
    
    //今日打卡记录
    BOOL checkinOK;
    BOOL checkoutOK;
}

@end

#define LOGIN_URL @"http://159.226.29.10:80/CnicCheck/authorization"
#define DAKA_URL @"http://159.226.29.10/CnicCheck/CheckServlet"
#define RECORDLIST_URL @"http://159.226.29.10/CnicCheck/CheckInfoServlet"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = [UIScreen mainScreen].bounds;
    size = rect.size;
    NSLog(@"(%f, %f)", size.width, size.height);
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refresh) name:@"refresh" object:nil];
    
    [self addItems];
    [self refresh];
}

- (void)addItems {
    
    topLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, size.width - 40, 30)];
    [topLabel1 setText:@"马凯"];
    [topLabel1 setTextAlignment:NSTextAlignmentLeft];
    [topLabel1 setTextColor:[UIColor blackColor]];
    [topLabel1 setFont:[UIFont systemFontOfSize:12]];
    [topLabel1 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topLabel1];
    
    topLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, size.width - 40, 30)];
    [topLabel2 setText:[NSString stringWithFormat:@"%@年%@月%@日", year, month, day]];
    [topLabel2 setTextAlignment:NSTextAlignmentCenter];
    [topLabel2 setTextColor:[UIColor blackColor]];
    [topLabel2 setFont:[UIFont systemFontOfSize:12]];
    [topLabel2 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topLabel2];
    
    topLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, size.width - 40, 30)];
    [topLabel3 setText:week];
    [topLabel3 setTextAlignment:NSTextAlignmentRight];
    [topLabel3 setTextColor:[UIColor blackColor]];
    [topLabel3 setFont:[UIFont systemFontOfSize:12]];
    [topLabel3 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:topLabel3];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, size.height * 0.165, size.width - 40, 50)];
    [statusLabel setText:@"您还没有上班打卡哦！"];
    [statusLabel setTextAlignment:NSTextAlignmentCenter];
    [statusLabel setTextColor:[UIColor colorWithRed:244 / 255. green:164 / 255. blue:96 / 255. alpha:1]];
    [statusLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:20]];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusLabel];
    
    UILabel *topLine1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 55, size.width - 10, .5)];
    [topLine1 setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:topLine1];
    UILabel *topLine2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 85, size.width - 10, .5)];
    [topLine2 setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:topLine2];
    
    float checkBtnHeight = 100;
    if (size.width == 320) {
        checkBtnHeight = 80;
    }
    
    checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkinBtn setFrame:CGRectMake(5, size.height * 0.3, size.width / 2 - 10 + 2.5, checkBtnHeight)];
    [checkinBtn setTitle:@"上班" forState:UIControlStateNormal];
    [checkinBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [checkinBtn addTarget:self action:@selector(checkBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    checkinBtn.tag = 0;
    [checkinBtn setBackgroundColor:[UIColor greenColor]];
    [checkinBtn.titleLabel setTextColor:[UIColor blackColor]];
    [checkinBtn.layer setMasksToBounds:YES];
    [checkinBtn.layer setCornerRadius:4];
    [self.view addSubview:checkinBtn];
    
    checkoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkoutBtn setFrame:CGRectMake(size.width / 2 + 2.5, size.height * 0.3, size.width / 2 - 10 + 2.5, checkBtnHeight)];
    [checkoutBtn setTitle:@"下班" forState:UIControlStateNormal];
    [checkoutBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [checkoutBtn addTarget:self action:@selector(checkBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    checkoutBtn.tag = 1;
    [checkoutBtn setBackgroundColor:[UIColor greenColor]];
    [checkoutBtn.titleLabel setTextColor:[UIColor blackColor]];
    [checkoutBtn.layer setMasksToBounds:YES];
    [checkoutBtn.layer setCornerRadius:4];
    [self.view addSubview:checkoutBtn];
    
    logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake(5, 20, 60, 30)];
    [logoutBtn setTitle:@"注销登录" forState:UIControlStateNormal];
    [logoutBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [logoutBtn setBackgroundColor:[UIColor grayColor]];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn.layer setMasksToBounds:YES];
    [logoutBtn.layer setCornerRadius:4];
    [self.view addSubview:logoutBtn];
    
    historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [historyBtn setFrame:CGRectMake(size.width - 65, 20, 60, 30)];
    [historyBtn setTitle:@"打卡记录" forState:UIControlStateNormal];
    [historyBtn setBackgroundColor:[UIColor colorWithRed:255 / 255. green:97 / 255. blue:0 alpha:1]];
    [historyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [historyBtn addTarget:self action:@selector(showHistoryView) forControlEvents:UIControlEventTouchUpInside];
    [historyBtn.layer setMasksToBounds:YES];
    [historyBtn.layer setCornerRadius:4];
    [self.view addSubview:historyBtn];
    
    UILabel *adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height - 40, size.width, 40)];
    [adLabel setText:@"广告位招租，长期有效，微信请联系：【drunkOldtown】"];
    [adLabel setFont:[UIFont systemFontOfSize:10]];
    [adLabel setBackgroundColor:[UIColor clearColor]];
    [adLabel setTextColor:[UIColor lightGrayColor]];
    [adLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:adLabel];
    
    UIImageView *tuodanView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width / 4 , size.height * 0.55, size.width / 2, size.width / 2)];
    [tuodanView setImage:[UIImage imageNamed:@"tuodan.jpg"]];
    [self.view addSubview:tuodanView];
    
    if ([self getData]) {
        NSLog(@"getData");
        topLabel1.text = [NSString stringWithFormat:@"你好，%@！", name];
        [checkinBtn setEnabled:YES];
        [checkoutBtn setEnabled:YES];
    }else {
        NSLog(@"noData");
        [self addWebView];
        [checkinBtn setEnabled:NO];
        [checkoutBtn setEnabled:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refresh];
}

#pragma mark - 刷新状态

- (void)refresh {
    
    NSLog(@"aaa");
    [self getDate];
    [self refreshStatus];
}

- (void)getDate {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    year = [NSString stringWithFormat:@"%ld", (long)[comps year]];
    month = [NSString stringWithFormat:@"%ld", (long)[comps month]];
    day = [NSString stringWithFormat:@"%ld", (long)[comps day]];
    
    NSArray *weekArray = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    week = [weekArray objectAtIndex:[comps weekday] - 1];
}

- (void)refreshStatus {
    
    if ([week isEqualToString:@"周六"] || [week isEqualToString:@"周日"]) {
        statusLabel.text = @"今天周末，不用打卡哦！";
        [checkinBtn setBackgroundColor:[UIColor greenColor]];
        [checkoutBtn setBackgroundColor:[UIColor greenColor]];
        [checkinBtn setEnabled:NO];
        [checkoutBtn setEnabled:NO];
    }else {
        [checkinBtn setEnabled:YES];
        [checkoutBtn setEnabled:YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *day_checkin = [defaults objectForKey:@"day_checkin"];
        NSString *day_checkout = [defaults objectForKey:@"day_checkout"];
        
        if ([day_checkin isEqualToString:day]) {
            checkinOK = [defaults boolForKey:@"status_checkin"];
        }else {
            checkinOK = false;
        }
        if ([day_checkout isEqualToString:day]) {
            checkoutOK = [defaults boolForKey:@"status_checkout"];
        }else {
            checkoutOK = false;
        }
        
        if (checkinOK) {
            [checkinBtn setBackgroundColor:[UIColor greenColor]];
            statusLabel.text = @"苦逼搬砖中...";
        }else {
            [checkinBtn setBackgroundColor:[UIColor redColor]];
            statusLabel.text = @"您还没有上班打卡哦~";
        }
        if (checkoutOK) {
            [checkoutBtn setBackgroundColor:[UIColor greenColor]];
            statusLabel.text = @"终于下班了！累死大爷了！";
        }else {
            [checkoutBtn setBackgroundColor:[UIColor redColor]];
        }
    }
    [topLabel2 setText:[NSString stringWithFormat:@"%@年%@月%@日", year, month, day]];
    [topLabel3 setText:week];
}


#pragma mark - 历史记录

- (void)showHistoryView {
    
    [self getRecordList];
}

- (void)getRecordList {
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:RECORDLIST_URL]];
    
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:@"" forKey:@"tm"];
    [request setTimeOutSeconds:5];
    [request startAsynchronous];
    
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        if (!data) {
            [self showMessage:@"网络错误！"];
        }else {
            NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //            NSLog(@"check dic: %@", dic);
            if (!array) {
                [self showMessage:@"网络错误！"];
            }else {
                recordArray = [NSMutableArray arrayWithArray:array];
                if (!recordArray) {
                    recordArray = [[NSMutableArray alloc] init];
                }
                NSLog(@"%@", recordArray[0]);
                [self addHistoryView];
                return;
            }
        }
    }];
    [request setFailedBlock:^{
        [self showMessage:@"网络错误！发送失败！"];
    }];
}

- (void)addHistoryView {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"record"];
    
//    NSLog(@"recordArray = %@", recordArray);
    
    //历史记录
    historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, size.width, size.height - 70) style:UITableViewStylePlain];
    [historyTableView setDataSource:self];
    [historyTableView setDelegate:self];
    [self.view addSubview:historyTableView];
    
    closeHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeHistoryBtn setFrame:CGRectMake(0, size.height - 50, size.width, 50)];
    [closeHistoryBtn setBackgroundColor:[UIColor colorWithRed:255 / 255. green:97 / 255. blue:0 alpha:1]];
    [closeHistoryBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeHistoryBtn addTarget:self action:@selector(closeHistoryView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeHistoryBtn];
}


- (void)addRecordWithType:(NSString *)type andSuccess:(NSString *)success {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *time = [formatter stringFromDate:date];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithString:name] forKey:@"name"];
    [dic setObject:[NSString stringWithString:type] forKey:@"type"];
    [dic setObject:[NSString stringWithString:time] forKey:@"time"];
    [dic setObject:[NSString stringWithString:success] forKey:@"success"];
    [dic setObject:[NSString stringWithString:day] forKey:@"day"];
    
    if (!recordArray) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *array = [defaults objectForKey:@"record"];
        recordArray = [NSMutableArray arrayWithArray:array];
        if (!recordArray) {
            recordArray = [[NSMutableArray alloc] init];
        }
    }
    [recordArray insertObject:dic atIndex:0];
    NSArray *array = [NSArray arrayWithArray:recordArray];
    NSUserDefaults *user = [[NSUserDefaults alloc] init];
    [user setObject:array forKey:@"record"];
    if ([type isEqualToString:@"上班"]) {
        [user setBool:YES forKey:@"status_checkin"];
        [user setObject:[NSString stringWithString:day] forKey:@"day_checkin"];
    }else if ([type isEqualToString:@"下班"]) {
        [user setBool:YES forKey:@"status_checkout"];
        [user setObject:[NSString stringWithString:day] forKey:@"day_checkout"];
    }
    [user synchronize];
    [self refresh];
}

#pragma mark - 点击关闭（打卡记录）按钮

- (void) closeHistoryView {
    
    [closeHistoryBtn removeFromSuperview];
    closeHistoryBtn = nil;
    [historyTableView removeFromSuperview];
    historyTableView = nil;
    
}

- (void)addWebView {
    
    loginWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LOGIN_URL]]];
    [self.view addSubview:loginWebView];
    loginWebView.delegate = self;
}

- (void)logout {
    [self addWebView];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"token"];
    [defaults setValue:nil forKey:@"name"];
    [defaults setBool:NO forKey:@"checkin"];
    [defaults setBool:NO forKey:@"checkout"];
    [defaults synchronize];
}

#pragma mark - 打卡
- (void)checkBtnTouch:(UIButton *)item {
    
    if ((checkinOK && item.tag == 0) || (checkoutOK && item.tag == 1)) {
        
        NSString *msg = @"";
        if (item.tag == 0) {
            msg = @"你已经打过上班的卡了，还要打吗？";
        }else {
            msg = @"你已经打过下班的卡了，还要打吗？";
        }
        UIAlertController *checkinAC = [UIAlertController alertControllerWithTitle:@"注意" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"坚持要打！" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self checkinout:item];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"好吧，不打了！" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [checkinAC addAction:action1];
        [checkinAC addAction:action2];
        [self presentViewController:checkinAC animated:YES completion:nil];
    }else {
        [self checkinout:item];
    }
}

- (void)checkinout:(UIButton *)item {
    
    /*
    if (item.tag == 0) {
        [self showMessage:@"上班打卡成功！"];
        [self addRecordWithType:@"上班" andSuccess:@"成功"];
    }else {
        [self showMessage:@"下班打卡成功！"];
        [self addRecordWithType:@"下班" andSuccess:@"成功"];
    }
    */
    
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:DAKA_URL]];
    
    int lon = arc4random() % 100000000;
    int lat = arc4random() % 100000000;
    
    NSString *jingdu = [NSString stringWithFormat:@"116.329%d", lon];
    NSString *weidu = [NSString stringWithFormat:@"39.979%d", lat];
//    NSLog(@"lon:%@ lat:%@", jingdu, weidu);
    NSString *type = @"";
    if (item.tag == 0) {
        type = @"checkin";
    }else {
        type = @"checkout";
    }
    
    [request setPostValue:jingdu forKey:@"jingdu"];
    [request setPostValue:weidu forKey:@"weidu"];
    [request setPostValue:type forKey:@"type"];
    [request setPostValue:token forKey:@"token"];
    [request setTimeOutSeconds:10];
    [request startAsynchronous];
    
    [request setCompletionBlock:^{
        NSData *data = [request responseData];
        if (!data) {
            [self showMessage:@"网络错误！"];
        }else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //            NSLog(@"check dic: %@", dic);
            if (!dic) {
                [self showMessage:@"网络错误！"];
            }else {
                NSString *success = [dic objectForKey:@"success"];
                if ([success isEqualToString:@"false"]) {
                    NSString *errorMessage = [dic objectForKey:@"errorMessage"];
                    [self showMessage:errorMessage];
                }else {
                    if (item.tag == 0) {
                        [self showMessage:@"上班打卡成功！"];
                        [self addRecordWithType:@"上班" andSuccess:@"成功"];
                    }else {
                        [self showMessage:@"下班打卡成功！"];
                        [self addRecordWithType:@"下班" andSuccess:@"成功"];
                    }
                }
            }
        }
    }];
    [request setFailedBlock:^{
        [self showMessage:@"网络错误！发送失败！"];
    }];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *html = [loginWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    NSLog(@"%@", html);
    if ([html containsString:@"refreshToken"]) {
        [loginWebView removeFromSuperview];
        loginWebView = nil;
        NSString *str1 = [html substringFromIndex:19];
        NSString *str = [str1 stringByReplacingOccurrencesOfString:@"\n</body>" withString:@""];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        token = [dic valueForKey:@"token"];
        name = [dic valueForKey:@"uname"];
        [self saveData:token name:name];
        topLabel1.text = [NSString stringWithFormat:@"你好，%@！", name];
        [checkinBtn setEnabled:YES];
        [checkoutBtn setEnabled:YES];
    }
}

- (void)saveData:(NSString *)_token name:(NSString *) username {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_token forKey:@"token"];
    [defaults setValue:username forKey:@"name"];
    [defaults synchronize];
}

- (BOOL)getData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    token = [defaults stringForKey:@"token"];
    name = [defaults stringForKey:@"name"];
    if (!token || !name) {
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    NSDictionary *dic = [recordArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        NSLog(@"0000 %@", dic);
    }
    NSString *type = @"上班";
    if ([[dic objectForKey:@"type"] isEqualToString:@"checkout"]) {
        type = @"下班";
    }
    NSString *leftStr = [NSString stringWithFormat:@"%@\t   %@", type, [dic objectForKey:@"indbTime"]];
    
    NSString *rightStr = @"成功";
    if (![[dic objectForKey:@"checkResult"] isEqualToString:@"true"]) {
        rightStr = @"失败";
    }
    [dic objectForKey:@"checkResult"];
    cell.textLabel.text = leftStr;
    cell.detailTextLabel.text = rightStr;
    if ([rightStr isEqualToString:@"成功"]) {
        cell.detailTextLabel.textColor = [UIColor greenColor];
    }else {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return recordArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

#pragma mark - 显示消息
- (void)showMessage:(NSString *)message {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(size.width / 3, 250, size.width / 2, 50)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.7]];
    [label setText:message];
    [label setAlpha:0];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor whiteColor]];
    [label.layer setCornerRadius:6];
    label.layer.masksToBounds = YES;
    [self.view addSubview:label];
    
    [UIView animateWithDuration:.6 animations:^{
        [label setAlpha:1];
        [label setCenter:CGPointMake(label.center.x, label.center.y - 25)];
    } completion:^(BOOL finished) {
        
        [UIView animateKeyframesWithDuration:.6 delay:.5 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            [label setAlpha:0];
            [label setCenter:CGPointMake(label.center.x, label.center.y - 25)];
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
