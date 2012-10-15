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

@interface TimeLineViewController : UITableViewController
@property (strong, nonatomic) ACAccount *twitterAccount;
@property (strong, nonatomic) NSArray *twitterTimeline;
- (IBAction)btnDownloadTouched:(id)sender;
@property (assign, nonatomic) UIFont *textFont;
@end
