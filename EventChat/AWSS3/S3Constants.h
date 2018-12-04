//
//  S3Constants.h
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>

static NSString *const CognitoPoolID = @"us-east-1:56f77ba0-429a-4ea1-9d74-916922fc8e00";
static NSString *const S3BucketName = @"ioseventchat";
static NSString * const awsURL   = @"https://s3.amazonaws.com/ioseventchat/";

#define TIME_IN_SECS [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
#define kS3PhotoURLPath(x,y) [NSString stringWithFormat:@"%@/i%@.png",x,y]
#define kS3PhotoThumbnailURLPath(x,y) [NSString stringWithFormat:@"%@/t%@.png",x,y]

#define PHOTO_FILE_PATH   [NSString stringWithFormat:@"%@/Images",S3BucketName]
#define VIDEO_FILE_PATH   [NSString stringWithFormat:@"%@/Videos",S3BucketName]


@interface S3Constants : NSObject

@end
