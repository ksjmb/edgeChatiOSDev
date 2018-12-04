//
//  ECColor.h
//  EventChat
//
//  Created by Jigish Belani on 2/15/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ECColor : NSObject

+ (UIColor *)tealColor;
+ (UIColor *)purpleColor;
+ (UIColor *)sponseredColor;
+ (UIColor *)acknowledgedColor;
+ (UIColor *)ecMagentaColor;
+ (UIColor *)ecSubTextGrayColor;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)appleBlue;
+ (UIColor *)mainThemeColor;
@end
