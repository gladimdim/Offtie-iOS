//
//  Downloader.h
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimelineUIDocument.h"


@interface DownloaderCallBack : NSObject
-(void) downloadedDict:(NSDictionary *) dict;
@end

@interface Downloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (strong) NSURL *url;
@property (strong) NSURL *docURL;
@property (strong) NSMutableData *receivedData;
@property (strong) NSString *id;
@property (strong) id delegate;

-(void) saveTweet;


@end
