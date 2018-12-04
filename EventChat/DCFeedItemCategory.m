//
//  DCFeedItemCategory.m
//  EventChat
//
//  Created by Jigish Belani on 1/6/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCFeedItemCategory.h"

@implementation DCFeedItemCategory
+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"categoryId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
