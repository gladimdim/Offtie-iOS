//
//  TimeLineViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 8/26/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "TimeLineViewController.h"
#import "PageViewController.h"
#import "TimelineUIDocument.h"

@interface TimeLineViewController ()
@property (strong) NSMutableArray *arrayOfHTMLDicts;
@property (strong) NSData *twitterResponseData;
@property (strong, nonatomic) PageViewController *pageViewController;
@property NSUserDefaults *sharedDefaults;
@end

@implementation TimeLineViewController

#define LAST_DOWNLOAD_DATE_TIME @"lastDownloadDateTime"

NSUInteger DeviceSystemMajorVersion();
NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

#define IOS7_VERSION (DeviceSystemMajorVersion() >= 7)

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
        self.pageViewController = (PageViewController *) [navController.viewControllers lastObject];
    }
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.gladimdim.Offtie"];
    [self.btnRefreshDownload setTitle:NSLocalizedString(@"Refresh & Download", nil)];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textFont = IOS7_VERSION ? [UIFont fontWithName:@"HelveticaNeue-Light" size:18] :[UIFont boldSystemFontOfSize:15.0f];
    self.barBtnStatus.title = @"Loading data";
    [self checkOnlineOfflineMode];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"text"];
    CGSize constrains = CGSizeMake(280.0f, MAXFLOAT);
    CGSize size = [text sizeWithFont:self.textFont constrainedToSize:constrains lineBreakMode:NSLineBreakByWordWrapping];

    return size.height + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.twitterTimeline.count;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tweetId = [[[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"id"] stringValue];
    NSString *htmlString = [self.timelineDoc.savedTimeline.dictOfHTMLPagesById valueForKey:tweetId];
    if (htmlString && ![htmlString isEqualToString:@""]) {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTimeLine";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = self.textFont;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap;
    cell.textLabel.adjustsFontSizeToFitWidth = IOS7_VERSION ? YES : NO;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"text"];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //Wed Dec 01 17:08:03 +0000 2010
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [df setDateFormat:@"eee MMM ddd HH:mm:ss ZZZ yyyy"];
    NSDictionary *dict = [self.twitterTimeline objectAtIndex:indexPath.row];
    NSString *stringDate = [dict objectForKey:@"created_at"];
    //Thu Oct 25 19:18:26 +0000 2012
    NSDate *date = [df dateFromString:stringDate];
    [df setDateFormat:@"eee MMM dd HH:mm"];
    NSString *dateStr = [df stringFromDate:date];
    NSString *authorName = [[[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:@"name"];
    
    NSString *detailedTextString = [NSString stringWithFormat:@"%@ on %@", authorName , dateStr];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:detailedTextString];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, authorName.length )];
    [cell.detailTextLabel setAttributedText:attrString];

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tweetId = [[[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"id"] stringValue];
    NSString *htmlString = [self.timelineDoc.savedTimeline.dictOfHTMLPagesById valueForKey:tweetId];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self reloadWebView:self.pageViewController];
    }
    else {
        if (htmlString && ![htmlString isEqualToString:@""]) {
            [self performSegueWithIdentifier:@"ShowWebView" sender:self];
        }
        else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

//save last downloaded time for selected twitter account name. date is saved under different keys for different accounts.
//the format of key is: username-NSDate.
-(NSDate *) updateLastDownloadDateTime {

    NSDate *currentDate = [NSDate date];
    NSLog(@"date update: %@", currentDate);
    
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:[NSString stringWithFormat:@"%@-%@", self.twitterAccount.username, LAST_DOWNLOAD_DATE_TIME]];
    [self.sharedDefaults setObject:currentDate forKey:[NSString stringWithFormat:@"%@-%@", self.twitterAccount.username, LAST_DOWNLOAD_DATE_TIME]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.sharedDefaults synchronize];
    NSLog(@"shared: %@", [self.sharedDefaults objectForKey:[NSString stringWithFormat:@"%@-%@", self.twitterAccount.username, LAST_DOWNLOAD_DATE_TIME]]);
    NSLog(@"all dict: %@", [self.sharedDefaults dictionaryRepresentation]);
    return currentDate;
}

//get last downloaded time for selected twitter account name. date is saved under different keys for different accounts.
//the format of key is: username-NSDate.
-(NSDate *) getLastDownloadDateTime {
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", self.twitterAccount.username, LAST_DOWNLOAD_DATE_TIME]];
    return  lastUpdate;
}

-(void) updateBarButtonWithLastDownloadTime {
    NSString *date = [NSDateFormatter localizedStringFromDate:[self getLastDownloadDateTime] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    self.barBtnStatus.title = [NSString stringWithFormat: NSLocalizedString(@"Updated on: %@", nil), date ? date : NSLocalizedString(@"Never", nil) ];
}

-(void) checkOnlineOfflineMode {
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:self.twitterAccount.username]];

    if (!self.timelineDoc) {
        self.timelineDoc = [[TimelineUIDocument alloc] initWithFileURL:docURL];
        [self.timelineDoc openWithCompletionHandler:^(BOOL success){
            NSLog(@"opened timeline file: %@", success ? @"YES" : @"NO");
            if (success) {
                NSArray *timeline = [NSJSONSerialization JSONObjectWithData:self.timelineDoc.savedTimeline.timelineData options:NSJSONReadingAllowFragments error:nil];
                if (timeline) {
                    self.twitterTimeline = timeline;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.barBtnStatus.title = @"Found offline files";
                        [self updateBarButtonWithLastDownloadTime];
                        [self.tableView reloadData];
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.barBtnStatus.title = NSLocalizedString(@"Getting timeline", nil);
                });
                [self downloadTwitterTimeLine];
            }
        }];
    }
    else {
        [self updateBarButtonWithLastDownloadTime];
    }
}


-(void) downloadTwitterTimeLine {
    self.counterOfDownloads = 0;
    self.amountOfTweetsWithURL = 0;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"]; //home
    NSDictionary *dict = @{@"count": @"20"};
    SLRequest *timeLineRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:dict];
    timeLineRequest.account = self.twitterAccount;
    [timeLineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.barBtnStatus.title = NSLocalizedString(@"Connection error", nil);
                self.btnRefreshDownload.enabled = YES;
            });
        }
        if ([urlResponse statusCode] == 200) {
            self.twitterResponseData = responseData;
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
            if (timeline) {
                self.twitterTimeline = timeline;
                //NSLog(@"timeline first: %@", [timeline lastObject]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update last download time
                    [self updateLastDownloadDateTime];
                    [self.tableView reloadData];
                    [self saveTweetsToDisk];
                });
            }
        }
        //recieved not-ok response from twitter (either twitter account is disabled in iOS or any other error
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error while getting data", nil) message:NSLocalizedString(@"Please check that Internet connection is available or access is enabled for Offtie application at Settings->Twitter", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil];
                [alert show];
                self.btnRefreshDownload.enabled = YES;
                [self updateBarButtonWithLastDownloadTime];
            });
        }
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PageViewController *pageView = (PageViewController *) segue.destinationViewController;
    [self reloadWebView:pageView];
}

-(void) reloadWebView:(PageViewController *) pageView {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger selectedRow = indexPath.row;
    NSString *id = [[[self.twitterTimeline objectAtIndex:selectedRow] valueForKey:@"id"] stringValue];
    NSString *htmlString = [self.timelineDoc.savedTimeline.dictOfHTMLPagesById valueForKey:id];
    pageView.htmlString = htmlString;
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [pageView updateWebView];
    }    
}

-(void) saveTweetsToDisk {
    NSLog(@"Entering saveTweetsToDisk");
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:self.twitterAccount.username]];
    [[NSFileManager defaultManager] removeItemAtURL:docURL error:nil];
    self.timelineDoc = [[TimelineUIDocument alloc] initWithFileURL:docURL];
    self.timelineDoc.savedTimeline = [[SavedTimeline alloc] init];
    self.timelineDoc.savedTimeline.timelineData = self.twitterResponseData;
    self.timelineDoc.savedTimeline.dictOfHTMLPagesById = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < self.twitterTimeline.count; i++) {
        NSArray *urlArray = [[[[self.twitterTimeline objectAtIndex:i] valueForKey:@"entities"] valueForKey:@"urls"] valueForKey:@"url"];
        if (urlArray.count > 0) {
            NSString *url = [urlArray objectAtIndex:0];
            if (url) {
                //NSLog(@"url: %@", url);
                Downloader *downloader = [[Downloader alloc] init];
                downloader.url = [NSURL URLWithString:url];
                downloader.id = [[[self.twitterTimeline objectAtIndex:i] valueForKey:@"id"] stringValue];
                downloader.delegate = self;
                self.amountOfTweetsWithURL++;
                [downloader saveTweet];
            }
        }
    }
}


/*
 DownloaderInterface implementations
 */
-(void) downloadedDict:(NSDictionary *) dict {
    //NSLog(@"entering downloadedDict with dict: %@", dict);
    if (dict) {
//        [self.timelineDoc.savedTimeline.setOfHTMLPagesById addObject:dict];
        [self.timelineDoc.savedTimeline.dictOfHTMLPagesById addEntriesFromDictionary:dict];
        //update barbutton title to reflect progress of downloads
        self.counterOfDownloads++;
        self.barBtnStatus.title = [NSString stringWithFormat:NSLocalizedString(@"Downloaded: %i/%i", nil), self.counterOfDownloads, self.amountOfTweetsWithURL];
        if (self.counterOfDownloads == self.amountOfTweetsWithURL) {
            self.btnRefreshDownload.enabled = YES;
            [self updateBarButtonWithLastDownloadTime];
            [self.tableView reloadData];
        }
    }
    [self.timelineDoc updateChangeCount:UIDocumentChangeDone];
    if (self.counterOfDownloads == self.amountOfTweetsWithURL) {
        [self.timelineDoc saveToURL:self.timelineDoc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            NSLog(@"savedfile to url: %@", success ? @"YES" : @"NO");
        }];
    }
}

//if empty html was received - decrease overal amount of tweets counter
-(void) errorWhileGettingPageReceived {
    self.amountOfTweetsWithURL--;
}



- (IBAction)btnDownloadTouched:(id)sender {
    self.barBtnStatus.title = NSLocalizedString(@"Preparing to update", nil);
    //downloading new timeline. If success tweets are autostored to disk
    self.btnRefreshDownload.enabled = NO;
    [self downloadTwitterTimeLine];
}

- (void)viewDidUnload {
    [self setBarBtnStatus:nil];
    [self setTableView:nil];
    [self setBtnRefreshDownload:nil];
    [super viewDidUnload];
}
@end
