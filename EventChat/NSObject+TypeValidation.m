#import "NSObject+TypeValidation.h"

@implementation NSObject (TypeValidation)

#pragma mark -

- (BOOL)isString {
  return [self isKindOfClass:[NSString class]];
}

- (BOOL)isNumber {
  return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)isDate {
  return [self isKindOfClass:[NSDate class]];
}

- (BOOL)isData {
  return [self isKindOfClass:[NSData class]];
}

- (BOOL)isArray {
  return [self isKindOfClass:[NSArray class]];
}

- (BOOL)isDictionary {
  return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL)isNull {
  return [self isKindOfClass:[NSNull class]];
}

#pragma mark -

- (NSString *)stringOrNilValue {
  return [self isString] ? (NSString *)self : nil;
}

- (NSNumber *)numberOrNilValue {
  return [self isNumber] ? (NSNumber *)self : nil;
}

- (NSDate *)dateOrNilValue {
  return [self isDate] ? (NSDate *)self : nil;
}

- (NSData *)dataOrNilValue {
  return [self isData] ? (NSData *)self : nil;
}

- (NSArray *)arrayOrNilValue {
  return [self isArray] ? (NSArray *)self : nil;
}

- (NSDictionary *)dictionaryOrNilValue {
  return [self isDictionary] ? (NSDictionary *)self : nil;
}

- (NSNull *)nullOrNilValue {
  return [self isNull] ? (NSNull *)self : nil;
}

@end
