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
    if (self.url == nil) {
        return;
    }
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

//when download finishes we send back to delegate NSDictionary with tweet id and appropriate html string for its URL
-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *htmlString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    if (htmlString == nil) {
        NSLog(@"Empty html returned for url: %@", self.url);
        [self.delegate errorWhileGettingPageReceived];
        return;
    }
    else {
        [self.delegate downloadedDict:[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:htmlString] forKeys:[NSArray arrayWithObject:self.id]]];
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate errorWhileGettingPageReceived];
}

@end
