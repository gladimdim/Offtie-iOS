//
//  TweetsHTMLString.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "TweetsHTMLString.h"

@implementation TweetsHTMLString

-(BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSData *data = [NSData dataWithData:contents];
    if ([contents length] > 0) {
        self.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        self.htmlString = @"";
    }
    return YES;
}

-(id) contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.htmlString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
}

@end
