//
//  CustomButton.m
//  EventChat
//
//  Created by Jigish Belani on 1/18/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addBorderForSide:(UIButtonBorderSide)side color:(UIColor *)color width:(CGFloat)width{
    
    CALayer *border = [CALayer layer];
    
    border.backgroundColor = [color CGColor];
    
    switch (side) {
        case Top:
            border.frame = CGRectMake(0, 0, self.frame.size.width, width);
            break;
        case Bottom:
            border.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width);
            break;
        case Left:
            border.frame = CGRectMake(0, 0, width, self.frame.size.height);
            break;
        case Right:
            border.frame = CGRectMake(self.frame.size.width - width, (self.frame.size.height - self.frame.size.height * 0.6) / 2, width, self.frame.size.height * 0.6);
            break;
        default:
            break;
    }
    
    [self.layer addSublayer:border];
    
}

@end
