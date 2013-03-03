//
//  TimeLineCollectionViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 12/16/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "TimeLineCollectionViewController.h"
#import "PageViewController.h"

@interface TimeLineCollectionViewController ()
@property (strong) NSMutableArray *arrayOfHTMLDicts;
@property (strong) NSData *twitterResponseData;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) PageViewController *pageViewController;
@end

#define LAST_DOWNLOAD_DATE_TIME @"lastDownloadDateTime"

@implementation TimeLineCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.pageViewController = (PageViewController *) [self.splitViewController.viewControllers lastObject];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CollectionViewCustomLayout *layout = [[CollectionViewCustomLayout alloc] init];
    layout.arrayOfData = self.twitterTimeline;
    self.collectionView.collectionViewLayout = layout;

    self.textFont = [UIFont boldSystemFontOfSize:15.0f];
    self.barBtnStatus.title = @"Loading data";
    [self checkOnlineOfflineMode];
    
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.twitterTimeline.count;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellTweet";
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *labelText = (UILabel *) [cell.contentView viewWithTag:2];
    labelText.font = self.textFont;
    labelText.textAlignment = UITextAlignmentLeft;
    labelText.lineBreakMode = UILineBreakModeWordWrap;
    labelText.adjustsFontSizeToFitWidth = YES;
    labelText.numberOfLines = 0;
    labelText.text = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"text"];
    
    /*NSString *date = [[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"created_at"];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
     
     NSDate *nsDate = [dateFormatter dateFromString:date];
     [dateFormatter setDateFormat:@"eee dd HH:mm"];
     */
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
    
    UILabel *labelAuthor = (UILabel *) [cell.contentView viewWithTag:1];
    labelAuthor.text = authorName;
    UILabel *labelDate = (UILabel *) [cell.contentView viewWithTag:3];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:authorName];
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, authorName.length )];
    [labelAuthor setAttributedText:attrString];
    
    NSMutableAttributedString *attrStringDate = [[NSMutableAttributedString alloc] initWithString:dateStr];
    [attrStringDate addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:NSMakeRange(0, dateStr.length)];
    [labelDate setAttributedText:attrStringDate];
        
//    [cell.detailTextLabel setAttributedText:attrString];
    // Configure the cell...
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tweetId = [[[self.twitterTimeline objectAtIndex:indexPath.row] valueForKey:@"id"] stringValue];
    NSString *htmlString = [self.timelineDoc.savedTimeline.dictOfHTMLPagesById valueForKey:tweetId];
    if (htmlString && ![htmlString isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"ShowWebView" sender:self];
    }
    else {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
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
    NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
    NSInteger selectedRow = indexPath.row;
    NSString *id = [[[self.twitterTimeline objectAtIndex:selectedRow] valueForKey:@"id"] stringValue];
    
    NSString *htmlString = [self.timelineDoc.savedTimeline.dictOfHTMLPagesById valueForKey:id];
    pageView.htmlString = htmlString;
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

//save last downloaded time for selected twitter account name. date is saved under different keys for different accounts.
//the format of key is: username-NSDate.
-(NSDate *) updateLastDownloadDateTime {
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"date update: %@", currentDate);
    
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:[NSString stringWithFormat:@"%@-%@", self.twitterAccount.username, LAST_DOWNLOAD_DATE_TIME]];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
                        [self.collectionView reloadData];
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
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"20" forKey:@"count"];
    TWRequest *timeLineRequest = [[TWRequest alloc] initWithURL:url parameters:dict requestMethod:TWRequestMethodGET];
    timeLineRequest.account = self.twitterAccount;
    [timeLineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.barBtnStatus.title = NSLocalizedString(@"Connection error", nil);
                self.btnRefreshDownload.enabled = YES;
            });
        }
        NSLog(@"response: %d", [urlResponse statusCode]);
        NSLog(@"response size: %u", [responseData length]);
        if ([urlResponse statusCode] == 200) {
            self.twitterResponseData = responseData;
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
            if (timeline) {
                self.twitterTimeline = timeline;
                //NSLog(@"timeline first: %@", [timeline lastObject]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update last download time
                    [self updateLastDownloadDateTime];
                    [self.collectionView reloadData];
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
            [self.collectionView reloadData];
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



@end
