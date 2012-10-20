//
//  OfftieTableViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 8/26/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "OfftieTableViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TimeLineViewController.h"

@interface OfftieTableViewController ()
@property (assign, nonatomic) ACAccount *twitterAccount;
@property NSArray *accounts;
@property ACAccountStore *accountStore;
@end

@implementation OfftieTableViewController

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
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeTwitter =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
                                 withCompletionHandler:^(BOOL granted, NSError *error) {
                                     if (granted) {
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             self.accounts = [self.accountStore
                                                              accountsWithAccountType:accountTypeTwitter];
                                             [self.tableView reloadData];
                                         });
                                     }
                                     else {
                                         NSLog(@"Error occured while requesting access to twitter: %@", [error.userInfo valueForKey:NSLocalizedDescriptionKey]);
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView reloadData];
                                         });
                                     }
                                 }];
    [self updateBarButtonDataStatistics];
}

- (void)viewDidUnload
{
    [self setBtnBarDeleteDownloadedData:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   // NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.timelineDoc.fileURL path]   error:nil];
   // return [attributes objectForKey:@"NSFileSize"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Select twitter account: ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.accounts) {
        return [self.accounts count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellAccountsList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ACAccount *acc = [self.accounts objectAtIndex:indexPath.row];
    if (acc) {
        cell.textLabel.text = acc.username;
        self.tableView.allowsSelection = YES;
    }
    else {
        cell.textLabel.text = @"No accounts available";
        self.tableView.allowsSelection = NO;
    }

    return cell;
}

-(void) updateBarButtonDataStatistics {
    NSError *error;
    NSURL *urlDocuments = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *arrayOfKeys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
    NSArray *arrayOfFilesURL = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:urlDocuments includingPropertiesForKeys:arrayOfKeys options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    NSNumber *sizeOfFiles = [[NSNumber alloc] init];
    double sum = 0;
    for (int i = 0; i < arrayOfFilesURL.count; i++) {
        NSError *error;
        NSDictionary *dictAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[arrayOfFilesURL objectAtIndex:i] path] error:&error];
        NSLog(@"dictAttributes: %@", [dictAttributes valueForKey:NSFileSize]);
        sum += [[dictAttributes valueForKey:NSFileSize] intValue];
    }
    sizeOfFiles = [NSNumber numberWithDouble:sum / 1000000.0];
    self.btnBarDeleteDownloadedData.title =[NSString stringWithFormat:@"Delete data: %.1fMb", [sizeOfFiles doubleValue]];
    //self.btnBarDeleteDownloadedData.tintColor = [UIColor redColor];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (self.accounts) {
        [self performSegueWithIdentifier:@"ShowAccountTimeLine" sender:self];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowAccountTimeLine"]) {
        TimeLineViewController *tvc = (TimeLineViewController *) segue.destinationViewController;
        tvc.twitterAccount = [self.accounts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
}

- (IBAction)btnBarDeleteDownloadedDataPressed:(id)sender {
    NSError *errorContentsOfDirectory;
    NSURL *urlDocuments = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *arrayOfKeys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
    NSArray *arrayOfFilesURL = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:urlDocuments includingPropertiesForKeys:arrayOfKeys options:NSDirectoryEnumerationSkipsHiddenFiles error:&errorContentsOfDirectory];
    for (int i = 0; i < arrayOfFilesURL.count; i++)    {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:arrayOfFilesURL[i] error:&error];
        if (error) {
            NSLog(@"Error %@ occured during deleting of %@", error, arrayOfFilesURL[i]);
        }
    }
    [self updateBarButtonDataStatistics];
}
@end
