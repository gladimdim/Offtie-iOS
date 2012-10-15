//
//  Downloader.m
//  Offtie
//
//  Created by Dmytro Gladkyi on 10/15/12.
//  Copyright (c) 2012 Dmytro Gladkyi. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader



-(void) saveTweet {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection ) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    else {
        NSLog(@"Failed to open connection for request: %@", request);
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *htmlString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    [self.delegate downloadedDict:[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:htmlString] forKeys:[NSArray arrayWithObject:self.id]]];
}

@end
