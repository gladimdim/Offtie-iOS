//
//  PageViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 9/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController
@synthesize webView;
@synthesize urlString;
@synthesize stringBodyHtml;

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
    [self.webView reload];
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadHTMLString:self.stringBodyHtml baseURL:nil];//[NSURL URLWithString:self.urlString]];
    NSLog(@"request: %@", self.webView.request);
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
