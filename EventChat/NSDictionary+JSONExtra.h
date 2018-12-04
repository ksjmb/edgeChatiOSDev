#import <Foundation/Foundation.h>
#import "NSObject+TypeValidation.h"

// JSON helper methods
// These all take a NSString key value only; no other objects may be used as keys.

@interface NSDictionary (JSONExtra)

- (NSString *)stringOrNilValueForKeyName:(NSString *)jsonKeyName;
- (NSNumber *)numberOrNilValueForKeyName:(NSString *)jsonKeyName;
- (NSDictionary *)dictionaryOrNilValueForKeyName:(NSString *)jsonKeyName;
- (NSArray *)arrayOrNilValueForKeyName:(NSString *)jsonKeyName;

@end
