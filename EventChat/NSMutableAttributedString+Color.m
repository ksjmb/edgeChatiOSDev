//
//  NSMutableAttributedString+Color.m
//  EventChat
//
//  Created by Jigish Belani on 11/12/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "NSMutableAttributedString+Color.h"


@implementation NSMutableAttributedString (Color)

-(void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color
{
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
}
@end
