//
//  ECAttendee.m
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECAttendee.h"

@implementation ECAttendee

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"attendeeId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}

@end
