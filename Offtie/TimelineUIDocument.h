//
//  TweetsHTMLString.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedTimeline.h"

@interface TimelineUIDocument : UIDocument
//@property SavedTweet *savedTweet;
@property (strong) SavedTimeline *savedTimeline;
@end
