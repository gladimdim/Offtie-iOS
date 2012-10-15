//
//  TweetsHTMLString.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "TimelineUIDocument.h"

@implementation TimelineUIDocument

-(BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if ([contents length] > 0) {
        //self.savedTweet = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)contents];
        self.savedTimeline = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)contents];
    }
    return YES;
}

-(id) contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    //return [NSKeyedArchiver archivedDataWithRootObject:self.savedTweet];
    return [NSKeyedArchiver archivedDataWithRootObject:self.savedTimeline];
}

@end
