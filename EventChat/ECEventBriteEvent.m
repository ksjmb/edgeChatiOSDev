#import "ECEventBriteEvent.h"
#import "ECEventBriteName.h"
#import "ECEventBriteLogo.h"
#import "ECEventBriteStart.h"
#import "ECEventBriteDescription.h"

@implementation ECEventBriteEvent

+ (JSONKeyMapper*)keyMapper
{
    // Mapping is <JSON key> : <property name>
    // Others are named the same and will be mapped automatically
    NSDictionary *mapperDictionary = @{ @"id" : @"eventId",
                                        @"description" : @"eventDescription"};
    
    return [[JSONKeyMapper alloc] initWithDictionary:mapperDictionary];
}
@end
