//
//  TodayViewController.m
//  OfftieToday
//
//  Created by Dmytro Gladkyi on 11/1/14.
//  Copyright (c) 2014 Dmytro Gladkyi. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <Accounts/Accounts.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource>
@property NSArray *accounts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

#define LAST_DOWNLOAD_DATE_TIME @"lastDownloadDateTime"

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) updateTwitterAccountList {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter =
    [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountTypeTwitter options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [accountStore accountsWithAccountType:accountTypeTwitter];
        }
        else {
            NSLog(@"Error occured while requesting access to twitter: %@", [error.userInfo valueForKey:NSLocalizedDescriptionKey]);
            self.accounts = nil;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self updateTwitterAccountList];
    completionHandler(NCUpdateResultNewData);
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.accounts.count;
    return count < 3 ? self.accounts.count : 3;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAccount"];
    if (indexPath.row < self.accounts.count) {
        ACAccount *account = self.accounts[indexPath.row];
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.gladimdim.Offtie"];
        NSDate *lastUpdateDate = [defaults objectForKey:[NSString stringWithFormat:@"%@-%@", account.username, LAST_DOWNLOAD_DATE_TIME]];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:lastUpdateDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
        cell.textLabel.text = account.username;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Last updated %@", dateString ? dateString : @"Never"];
    }
    

    
    return cell;
}


@end
