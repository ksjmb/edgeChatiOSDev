//
//  ECVideoData.m
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECVideoData.h"
#import "ECConstants.h"
@implementation ECVideoData

+ (id)sharedInstance
{
    static ECVideoData *sharedData = nil;
    if (nil != sharedData) {
        return sharedData;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[ECVideoData alloc] init];
    });
    return sharedData;
}

- (BOOL)saveVideoDataWithData:(NSDictionary *)dic{
    
    self.mediaURL           = [dic objectForKey:MGVvideoURL];
    self.mediaTitle         = [dic objectForKey:MGVvideoTitle];
    self.mediaDescription   = [dic objectForKey:MGVvideoDescription];
    self.mediaThumbImageURL = [dic objectForKey:MGVvideoThumbImageURL];
    self.hashTag            = [dic objectForKey:MGVhashTag];
    return YES;
}

@end
