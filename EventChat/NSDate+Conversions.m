#import "NSDate+Conversions.h"

@implementation NSDate (Conversions)
+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLenient:TRUE];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:format];
    return dateFormatter;
}

+ (NSDateFormatter *)standardFormat {
    return [self dateFormatterWithFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
}

+ (NSDateFormatter *)utcFormat {
    NSDateFormatter *dateFormatter = [self dateFormatterWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return dateFormatter;
}

+ (NSDateFormatter *)offsetFormat {
    NSDateFormatter *dateFormatter = [self dateFormatterWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    return dateFormatter;
}

- (NSString *)asString {
    return [[NSDate standardFormat] stringFromDate:self];
}

- (NSString *)asUTCString {
    return [[NSDate utcFormat] stringFromDate:self];
}

- (NSString *)asTzOffsetString {
    return [[NSDate offsetFormat] stringFromDate:self];
}

- (NSString *)asString:(NSString *)formatString {
    return [[NSDate dateFormatterWithFormat:formatString] stringFromDate:self];
}

+ (NSDate *)fromString:(NSString *)formattedDateString {
    if ([[formattedDateString substringFromIndex:formattedDateString.length - 1] isEqualToString:@"Z"]) {
        return [[self dateFormatterWithFormat:@"yyyy-MM-dd'T':HH:mm:ss.SSS'Z'"] dateFromString:formattedDateString];
    }
    return [[NSDate standardFormat] dateFromString:formattedDateString];
}

+ (NSDate *)fromUTCString:(NSString *)formattedDateString {
    return [[NSDate utcFormat] dateFromString:formattedDateString];
}

+ (NSDate *)fromTzOffsetString:(NSString *)formattedDateString {
    return [[NSDate offsetFormat] dateFromString:formattedDateString];
}

- (NSDate *)accurateToSeconds {
    return [NSDate fromString:[self asString]];
}

- (NSString *)relativeTime {
    return [NSDate relativeTime:self until:[NSDate date]];
}

+ (NSString *)relativeTime:(NSDate *)then until:(NSDate *) now {
    //Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [now timeIntervalSinceDate:then];

    if (delta < 1 * MINUTE) {
        return delta == 1 ? @"a second ago" : [NSString stringWithFormat:@"%d seconds ago", (int) delta];
    }
    if (delta < 2 * MINUTE) {
        return @"a minute ago";
    }
    if (delta < 45 * MINUTE) {
        int minutes = floor((double) delta / MINUTE);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    if (delta < 90 * MINUTE) {
        return @"an hour ago";
    }
    if (delta < 24 * HOUR) {
        int hours = floor((double) delta / HOUR);
        return [NSString stringWithFormat:@"%d hour%@ ago", hours, (hours == 1 ? @"" : @"s")];
    }
    if (delta < 48 * HOUR) {
        return @"yesterday";
    }
    if (delta < 30 * DAY) {
        int days = floor((double) delta / DAY);
        return [NSString stringWithFormat:@"%d day%@ ago", days, (days == 1 ? @"" : @"s")];
    }
    if (delta < 12 * MONTH) {
        int months = floor((double) delta / MONTH);
        return months <= 1 ? @"one month ago" : [NSString stringWithFormat:@"%d months ago", months];
    }
    else {
        int years = floor((double) delta / MONTH / 12.0);
        return years <= 1 ? @"one year ago" : [NSString stringWithFormat:@"%d years ago", years];
    }
}
@end
