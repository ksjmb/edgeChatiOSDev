//
//  DCFeedItemFilter.m
//  EventChat
//
//  Created by Jigish Belani on 1/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCFeedItemFilter.h"

@implementation DCFeedItemFilter
+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"filterId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
