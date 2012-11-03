//
//  TimeLineViewController.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 8/26/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "Downloader.h"

@interface TimeLineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DownloaderCallBack>
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (strong, nonatomic) NSArray *twitterTimeline;
- (IBAction)btnDownloadTouched:(id)sender;
@property (assign, nonatomic) UIFont *textFont;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnStatus;
@property (strong) TimelineUIDocument *timelineDoc;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property int counterOfDownloads;
@property int amountOfTweetsWithURL;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnRefreshDownload;
@end
