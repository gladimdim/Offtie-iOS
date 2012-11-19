//
//  DummyTimeLineViewController.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 9/16/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "DummyTimeLineViewController.h"

@interface DummyTimeLineViewController ()

@end

@implementation DummyTimeLineViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
