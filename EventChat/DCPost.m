//
//  DCPost.m
//  EventChat
//
//  Created by Jigish Belani on 2/4/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCPost.h"

@implementation DCPost
#pragma mark - JSON Model

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"postId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
