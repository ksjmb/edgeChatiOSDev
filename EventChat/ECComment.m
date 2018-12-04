#import "ECComment.h"

@implementation ECComment

#pragma mark - JSON Model

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"_id" : @"commentId" };
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}

@end
