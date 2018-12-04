//  Methods to simplify type validation of foundation objects.

#import <Foundation/Foundation.h>

@interface NSObject (TypeValidation)

- (BOOL)isString;
- (BOOL)isNumber;
- (BOOL)isDate;
- (BOOL)isData;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isNull;

- (NSString *)stringOrNilValue;
- (NSNumber *)numberOrNilValue;
- (NSDate *)dateOrNilValue;
- (NSData *)dataOrNilValue;
- (NSArray *)arrayOrNilValue;
- (NSDictionary *)dictionaryOrNilValue;
- (NSNull *)nullOrNilValue;

@end
