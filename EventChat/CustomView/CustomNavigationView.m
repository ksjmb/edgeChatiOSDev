//
//  CustomNavigationView.m
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "CustomNavigationView.h"
#import "ECConstants.h"

@implementation CustomNavigationView
+ (void)initialize
{
    if (self == [CustomNavigationView class]) {
        
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    self.backgroundColor = NAVIGATION_BAR_COLOR ;
    self.userInteractionEnabled = YES;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.layer.shadowRadius = 1.5f;
    self.layer.shadowOpacity =  0.40f ;
    
    // setUp title
    [self titleLabelSetUp];
    
    // setUp left button
    [self leftButtonSetUp];
    
    // setUp right button
    [self rightButtonSetUp];
}

- (void)titleLabelSetUp{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
    self.titleLabel.center = self.center;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:ROBOTO_REGULAR size:20];
    self.titleLabel.textColor = RGB(215, 213, 219);
    self.titleLabel.text = @"";
    [self addSubview:self.titleLabel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)leftButtonSetUp{
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(-1, -1, 70, 52)];
    [self addSubview:self.leftButton];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)rightButtonSetUp{
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-61, -1, 60, 52)];
    [self addSubview:self.rightButton];
}


@end
