//
//  TimeLineCollectionViewController.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 12/16/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "Downloader.h"
#import "CollectionViewCustomLayout.h"

@interface TimeLineCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, DownloaderCallBack>
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (strong, nonatomic) NSArray *twitterTimeline;
- (IBAction)btnDownloadTouched:(id)sender;
@property (assign, nonatomic) UIFont *textFont;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnStatus;
@property (strong) TimelineUIDocument *timelineDoc;
@property int counterOfDownloads;
@property int amountOfTweetsWithURL;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnRefreshDownload;
@end
