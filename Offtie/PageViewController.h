//
//  PageViewController.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 9/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedTimeline.h"

@interface PageViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong) NSString *htmlString;
@end
