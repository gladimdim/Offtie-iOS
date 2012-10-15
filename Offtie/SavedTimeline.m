//
//  SavedTweet.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "SavedTimeline.h"

@implementation SavedTimeline

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.timelineData = [aDecoder decodeObjectForKey:@"timelineData"];
        self.arrayOfHTMLPagesDicts = [aDecoder decodeObjectForKey:@"arrayOfHTMLPagesDicts"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.timelineData forKey:@"timelineData"];
    [aCoder encodeObject:self.arrayOfHTMLPagesDicts forKey:@"arrayOfHTMLPagesDicts"];
}

@end
