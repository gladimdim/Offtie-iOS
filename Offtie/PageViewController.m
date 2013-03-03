//
//  PageViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 9/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation PageViewController

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
    [self.tabBarController.tabBar setHidden:YES];
    [self setHidesBottomBarWhenPushed:YES];
    [self.webView reload];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //strange but htmlstring is actually a NSSet with one object - NSString.
    //when htmlstring is saved to disk it is still NSString, but when read back
    //it is read as NSSet. I did not find reason for this yet.
}

-(void) viewWillAppear:(BOOL)animated {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.navigationItem.title = NSLocalizedString(@"Select page from left menu", nil);
    }
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    NSLog(@"htmlstring size: %i", self.htmlString.length);
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
    
}

-(void) updateWebView {
    [self.webView loadHTMLString:self.htmlString baseURL:nil];
}


- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    if (self.htmlString) {
        self.navigationItem.title = NSLocalizedString(@"Page loaded", nil);
    }
}

-(void) webViewDidStartLoad:(UIWebView *)webView {
    if (self.htmlString) {
        self.navigationItem.title = NSLocalizedString(@"Loading page", nil);
    }
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.navigationItem.title = NSLocalizedString(@"Error loading page", nil);
    //NSLog(@"Error loading page: %@", error);
}

-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = NSLocalizedString(@"Timeline", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
