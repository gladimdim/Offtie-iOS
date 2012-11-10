//
//  OfftieTableViewController.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 8/26/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfftieTableViewController : UITableViewController
- (IBAction)btnRefreshPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBarDeleteDownloadedData;
- (IBAction)btnBarDeleteDownloadedDataPressed:(id)sender;
@end
