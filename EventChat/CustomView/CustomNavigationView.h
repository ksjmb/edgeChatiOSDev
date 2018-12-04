//
//  CustomNavigationView.h
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationView : UIView
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *titleLabel;

//- (void)autoScrollLabelSetUp:(NSString *)text scrollSpeed:(float)speed;

@end
