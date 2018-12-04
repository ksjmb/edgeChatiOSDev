//
//  DCPlaylist.m
//  EventChat
//
//  Created by Jigish Belani on 11/7/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCPlaylist.h"

@implementation DCPlaylist
+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"playlistId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
