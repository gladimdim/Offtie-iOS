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
@end

@implementation TimeLineViewController 

#define LAST_DOWNLOAD_DATE_TIME @"lastDownloadDateTime"

/*- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textFont = [UIFont boldSystemFontOfSize:15.0f];
    [self checkOnlineOfflineMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"text"];
    CGSize constrains = CGSizeMake(280.0f, MAXFLOAT);
    CGSize size = [text sizeWithFont:self.textFont constrainedToSize:constrains lineBreakMode:UILineBreakModeWordWrap];
    //NSLog(@"return size: %f", size.height + 30);
    return size.height + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.twitterTimeline.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTimeLine";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = self.textFont;
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"text"];
    cell.detailTextLabel.text = [[[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:@"name"];
    // Configure the cell...
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowWebView" sender:self];
}

-(NSDate *) updateLastDownloadDateTime {

    NSDate *currentDate = [NSDate date];
    NSLog(@"date update: %@", currentDate);
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:LAST_DOWNLOAD_DATE_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return currentDate;
}

-(NSDate *) getLastDownloadDateTime {
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_DOWNLOAD_DATE_TIME];
    return  lastUpdate;
}

-(void) updateBarButtonWithLastDownloadTime {
    self.barBtnStatus.title = [NSString stringWithFormat:@"Updated on: %@", [NSDateFormatter localizedStringFromDate:[self getLastDownloadDateTime] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
}

-(void) checkOnlineOfflineMode {
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:self.twitterAccount.username]];

    if (!self.timelineDoc) {
        self.timelineDoc = [[TimelineUIDocument alloc] initWithFileURL:docURL];
        [self.timelineDoc openWithCompletionHandler:^(BOOL success){
            NSLog(@"opened timeline file: %@", success ? @"YES" : @"NO");
            if (success) {
                NSArray *timeline = [NSJSONSerialization JSONObjectWithData:self.timelineDoc.savedTimeline.timelineData options:NSJSONWritingPrettyPrinted error:nil];
                if (timeline) {
                    self.twitterTimeline = timeline;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateBarButtonWithLastDownloadTime];
                        [self.tableView reloadData];
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.barBtnStatus.title = @"Getting timeline";
                });
                [self downloadTwitterTimeLine];
            }
        }];
    }
}


-(void) downloadTwitterTimeLine {
    self.counterOfDownloads = 0;
    self.amountOfTweetsWithURL = 0;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"count" forKey:@"count"];
    TWRequest *timeLineRequest = [[TWRequest alloc] initWithURL:url parameters:dict requestMethod:TWRequestMethodGET];
    timeLineRequest.account = self.twitterAccount;
    [timeLineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"response: %d", [urlResponse statusCode]);
        NSLog(@"response size: %u", [responseData length]);
        if ([urlResponse statusCode] == 200) {
            self.twitterResponseData = responseData;
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:nil];
            if (timeline) {
                self.twitterTimeline = timeline;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update last download time
                    [self updateLastDownloadDateTime];
                    [self.tableView reloadData];
                    [self saveTweetsToDisk];
                });
            }
        }
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*NSArray *urlArray = [[[[self.twitterTimeline objectAtIndex:self.tableView.indexPathForSelectedRow.row] valueForKey:@"entities"] valueForKey:@"urls"] valueForKey:@"url"];
    if (urlArray.count > 0) {
        NSString *url = [urlArray objectAtIndex:0];
        if (url) {
            NSLog(@"url: %@", url);
            PageViewController *pageView = (PageViewController *) segue.destinationViewController;
            pageView.urlString = url;
            //[webView loadRequest:request];
        }
    }*/
    PageViewController *pageView = (PageViewController *) segue.destinationViewController;
    NSUInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    NSString *id = [[[self.twitterTimeline objectAtIndex:selectedRow] valueForKey:@"id"] stringValue];
    NSString *htmlString = [self.timelineDoc.savedTimeline.setOfHTMLPagesById valueForKey:id];
    
    pageView.htmlString = htmlString;
}

-(void) saveTweetsToDisk {
    NSLog(@"Entering saveTweetsToDisk");
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:self.twitterAccount.username]];
    [[NSFileManager defaultManager] removeItemAtURL:docURL error:nil];
    self.timelineDoc = [[TimelineUIDocument alloc] initWithFileURL:docURL];
    self.timelineDoc.savedTimeline = [[SavedTimeline alloc] init];
    self.timelineDoc.savedTimeline.timelineData = self.twitterResponseData;
    self.timelineDoc.savedTimeline.setOfHTMLPagesById = [[NSMutableSet alloc] init];
    
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

-(void) downloadedDict:(NSDictionary *) dict {
    //NSLog(@"entering downloadedDict with dict: %@", dict);
    if (dict) {
        [self.timelineDoc.savedTimeline.setOfHTMLPagesById addObject:dict];
        //update barbutton title to reflect progress of downloads
        self.counterOfDownloads++;
        self.barBtnStatus.title = [NSString stringWithFormat:@"Downloaded: %i/%i", self.counterOfDownloads, self.amountOfTweetsWithURL];
        if (self.counterOfDownloads == self.amountOfTweetsWithURL) {
            [self updateBarButtonWithLastDownloadTime];
        }
    }
    [self.timelineDoc updateChangeCount:UIDocumentChangeDone];
    if (self.counterOfDownloads == self.amountOfTweetsWithURL) {
        [self.timelineDoc saveToURL:self.timelineDoc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            NSLog(@"savedfile to url: %@", success ? @"YES" : @"NO");
        }];
    }
}

- (IBAction)btnDownloadTouched:(id)sender {
    self.barBtnStatus.title = @"Preparing to update";
    //downloading new timeline. If success tweets are autostored to disk
    [self downloadTwitterTimeLine];
}

- (void)viewDidUnload {
    [self setBarBtnStatus:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
