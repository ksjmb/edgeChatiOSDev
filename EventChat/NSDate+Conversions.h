#import <Foundation/Foundation.h>

@interface NSDate (Conversions)
+ (NSDateFormatter *)offsetFormat;
-(NSString *)asString;

- (NSString *)asUTCString;
- (NSString *)asTzOffsetString;
-(NSString *)asString:(NSString *)formatString;
+(NSDate *)fromString:(NSString *)formattedDateString;

+ (NSDate *)fromUTCString:(NSString *)formattedDateString;
+ (NSDate *)fromTzOffsetString:(NSString *)formattedDateString;
- (NSDate *)accurateToSeconds;
- (NSString *)relativeTime;
+ (NSString *)relativeTime:(NSDate *)then until:(NSDate *)now;
@end
