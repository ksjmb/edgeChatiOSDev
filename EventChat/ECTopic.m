#import "ECTopic.h"

@implementation ECTopic

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"topicId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}

@end
