#import "ECJSONModel.h"

@implementation ECJSONModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    // Changing default to "all properties are optional".
    // Override this method in subclasses to make some/all properties required.
    //???: Do we want to do this, or should we leave this as NO to validate all responses?
    return YES;
}

// Optional methods to override in subclasses:

//+ (BOOL)propertyIsOptional:(NSString *)propertyName {
//  // Properties named here will validate even if they are set to nil, and they won't populate JSON string/dictionary with NSNull if property is nil
//  NSArray *optionalProperties = @[@"authToken", @"userId", @"firstName", @"lastName", @"name", @"email"];
//  return [optionalProperties containsObject:propertyName];
//}

//+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
//  // Properties named here will be completely ignored by JSONModel.
//  NSArray *ignoredProperties = @[];
//  return [ignoredProperties containsObject:propertyName];
//}

@end
