#import "NSDictionary+JSONExtra.h"

@implementation NSDictionary (JSONExtra)

- (NSString *)stringOrNilValueForKeyName:(NSString *)jsonKeyName {
  return [[self objectForKey:jsonKeyName] stringOrNilValue];
}

- (NSNumber *)numberOrNilValueForKeyName:(NSString *)jsonKeyName {
  return [[self objectForKey:jsonKeyName] numberOrNilValue];
}

- (NSDictionary *)dictionaryOrNilValueForKeyName:(NSString *)jsonKeyName {
  return [[self objectForKey:jsonKeyName] dictionaryOrNilValue];
}

- (NSArray *)arrayOrNilValueForKeyName:(NSString *)jsonKeyName {
  return [[self objectForKey:jsonKeyName] arrayOrNilValue];
}

@end
