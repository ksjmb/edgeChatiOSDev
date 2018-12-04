//
//  ECVideoRangeSlider.h
//  EventChat
//
//  Created by Mindbowser on 7/5/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ECVideoRangeSliderDelegate;

@interface ECVideoRangeSlider : UIView


@property (nonatomic, weak) id <ECVideoRangeSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;
@property (nonatomic, strong) UILabel *bubleText;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, assign) NSInteger maxGap;
@property (nonatomic, assign) NSInteger minGap;


- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;
- (void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height;


@end


@protocol ECVideoRangeSliderDelegate <NSObject>

@optional

- (void)videoRange:(ECVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)videoRange:(ECVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;


@end
