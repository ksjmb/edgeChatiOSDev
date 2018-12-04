//
//  CustomButton.h
//  EventChat
//
//  Created by Jigish Belani on 1/18/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Top,
    Bottom,
    Left,
    Right
} UIButtonBorderSide;

@interface CustomButton : UIButton
- (void)addBorderForSide:(UIButtonBorderSide)side color:(UIColor *)color width:(CGFloat)width;
@end
