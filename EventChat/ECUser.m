#import "ECUser.h"

@implementation ECUser

#pragma mark - JSON Model

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"userId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}

@end
