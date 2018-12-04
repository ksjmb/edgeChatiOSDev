//
//  ECColor.m
//  EventChat
//
//  Created by Jigish Belani on 2/15/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECColor.h"

@implementation ECColor
+ (UIColor *)colorWithDecimalRed:(float)red green:(float)green blue:(float)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)tealColor{
    return [ECColor colorWithDecimalRed:96 green:195 blue:177 alpha:1.0];
}

+ (UIColor *)purpleColor{
    return [ECColor colorWithDecimalRed:181 green:39 blue:108 alpha:1.0];
}

+ (UIColor *)sponseredColor{
    return [ECColor colorWithDecimalRed:250 green:205 blue:200 alpha:1.0];
}

+ (UIColor *)acknowledgedColor{
    return [ECColor colorWithDecimalRed:244 green:244 blue:244 alpha:1.0];
}

+ (UIColor *)ecMagentaColor{
    return [ECColor colorWithDecimalRed:164 green:15 blue:89 alpha:1.0];
}

+ (UIColor *)ecSubTextGrayColor{
    return [ECColor colorWithDecimalRed:127 green:127 blue:127 alpha:1.0];
}

+ (UIColor *)mainThemeColor{
    return [self colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor*)appleBlue{
    return [UIColor colorWithRed:14.0/255 green:122.0/255 blue:254.0/255 alpha:1.0];
}
@end
