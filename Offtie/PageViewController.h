//
//  PageViewController.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 9/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, readwrite) NSString *urlString;
@end
