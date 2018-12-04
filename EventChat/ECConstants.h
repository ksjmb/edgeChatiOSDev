//
//  ECConstants.h
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>

//constants
static NSString * const ECvideo                = @"video";
extern NSString *const kMediaBrowserMediaType;
extern NSString *const kMediaBrowserSourceType;
extern NSString *const kMediaBrowserIsForProfilePic;
extern NSString *const kMediaBrowserShouldCropImage;
static const NSInteger kMaximumVideoDuration = 15; // In seconds
static const NSInteger kMinimumVideoDuration = 5; // In seconds
static NSString * const ECMediaLength          = @"mediaLength";
static NSString * const ECAppName = @"EventChat";
static NSString * const MGVvideoURL             = @"videoURL";
static NSString * const MGVvideoTitle           = @"videoTitle";
static NSString * const MGVvideoDescription     = @"videoDescription";
static NSString * const MGVvideoThumbImageURL   = @"videoThumbImageURL";
static NSString * const MGVhashTag              = @"hashTag";
//staging

typedef NS_ENUM(NSInteger, SectionType){
    SectionNone,
    SectionVideos,
    SectionPhotos
};
//macros
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define NAVIGATION_BAR_COLOR    RGB(27, 16, 40)

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kS3VideoURLPath(x,y) [NSString stringWithFormat:@"%@/%@.mp4",x,y]
#define kS3VideoTImageURLPath(x,y) [NSString stringWithFormat:@"%@/%@.png",x,y]


//Fonts
#define ROBOTO_REGULAR      @"Roboto-Regular"

