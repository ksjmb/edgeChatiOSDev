//
//  ECFeedItem.m
//  EventChat
//
//  Created by Jigish Belani on 7/6/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCFeedItem.h"

@implementation DCFeedItem

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"feedItemId",
                                        @"description" : @"itemDescription" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
