//
//  SavedTweet.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedTimeline : NSObject <NSCoding>
@property NSData *timelineData;
@property NSMutableDictionary *setOfHTMLPagesById;
@end
