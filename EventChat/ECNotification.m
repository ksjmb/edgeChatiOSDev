#import "ECNotification.h"

@implementation ECNotification

#pragma mark - JSON Model

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"notificationId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}

@end
