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
@end

@implementation TimeLineViewController 

@synthesize twitterAccount;
@synthesize twitterTimeline;
@synthesize textFont;


#define TIMELINE_FILENAME @"timeline"

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


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
    NSLog(@"return size: %f", size.height + 30);
    return size.height + 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.twitterTimeline.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"entering cellForRow");
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

-(void) checkOnlineOfflineMode {
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:TIMELINE_FILENAME]];
    
    
    self.timelineDoc = [[TimelineUIDocument alloc] initWithFileURL:docURL];
    
    [self.timelineDoc openWithCompletionHandler:^(BOOL success){
        NSLog(@"opened timeline file: %@", success ? @"YES" : @"NO");
        if (success) {
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:self.timelineDoc.savedTimeline.timelineData options:NSJSONWritingPrettyPrinted error:nil];
            if (timeline) {
                self.twitterTimeline = timeline;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
        else {
            [self downloadTwitterTimeLine];
        }
    }];
}


-(void) downloadTwitterTimeLine {
    NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"count" forKey:@"count"];
    TWRequest *timeLineRequest = [[TWRequest alloc] initWithURL:url parameters:dict requestMethod:TWRequestMethodGET];
    timeLineRequest.account = self.twitterAccount;
    [timeLineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"response: %d", [urlResponse statusCode]);
        NSLog(@"response size: %u", [responseData length]);
        if ([urlResponse statusCode] == 200) {
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:nil];
            if (timeline) {
                self.twitterTimeline = timeline;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self saveTweetsToDisk];
                });
            }
            NSLog(@"count: %i", timeline.count);
            NSLog(@"first: %@", [timeline objectAtIndex:0]);
        }
    }];
    
     // [UIFont fontWithName:@"Arial" size:15.0f];

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
}

-(void) saveTweetsToDisk {
    NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *docURL = [NSURL URLWithString:[[baseURL absoluteString]  stringByAppendingString:TIMELINE_FILENAME]];

    [[NSFileManager defaultManager] removeItemAtURL:docURL error:nil];
    
    for (int i = 0; i < self.twitterTimeline.count; i++) {
        
        NSArray *urlArray = [[[[self.twitterTimeline objectAtIndex:self.tableView.indexPathForSelectedRow.row] valueForKey:@"entities"] valueForKey:@"urls"] valueForKey:@"url"];
        
        if (urlArray.count > 0) {
            NSString *url = [urlArray objectAtIndex:0];
            if (url) {
                NSLog(@"url: %@", url);
                Downloader *downloader = [[Downloader alloc] init];
                downloader.url = [NSURL URLWithString:url];
                downloader.id = [[[self.twitterTimeline objectAtIndex:i] valueForKey:@"id"] stringValue];
                downloader.delegate = self;
                [downloader saveTweet];
            }
        }
    }
}

-(void) downloadedDict:(NSDictionary *) dict {
    if (dict) {
        [self.timelineDoc.savedTimeline.arrayOfHTMLPagesDicts addObject:dict];
    }
}

- (IBAction)btnDownloadTouched:(id)sender {
    //downloading new timeline. If success tweets are autostored to disk
    [self downloadTwitterTimeLine];
}

@end
