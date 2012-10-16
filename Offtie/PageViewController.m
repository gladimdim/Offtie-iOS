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
    //strange but htmlstring is actually a NSSet with one object - NSString.
    //when htmlstring is saved to disk it is still NSString, but when read back
    //it is read as NSSet. I did not find reason for this yet.
#warning figure out why htmlString is not NSString but NSSet
    NSSet *set = (NSSet *) self.htmlString;
    NSEnumerator *enumerator = [set objectEnumerator];
    id value;
    value = [enumerator nextObject];
    [self.webView loadHTMLString:value baseURL:[NSURL URLWithString:@"http://google.com"]];
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
