//
//  ECVideoData.h
//  EventChat
//
//  Created by Mindbowser on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ECVideoData : NSObject

+ (id)sharedInstance;
- (BOOL)saveVideoDataWithData:(NSDictionary *)dic;

// common parameters
@property (nonatomic, strong) NSString *    mediaTitle;
@property (nonatomic, strong) NSString *    mediaDescription;
@property (nonatomic, strong) NSString *    hashTag;
@property (nonatomic, strong) NSString *    mediaURL;
@property (nonatomic, strong) NSString *    mediaUniqueId;


// for image object parameters
@property (nonatomic, strong) UIImage *     mediaImage;


// for video object parameters
@property (nonatomic, strong) NSString  *   mediaThumbImageURL;
@property (nonatomic, strong) NSURL     *   mediaDataFilePath;
@property (nonatomic, strong) UIImage   *   mediaThumbImage;
@property (nonatomic,strong)  NSData    *   videoData;
@property (nonatomic,strong)  NSURL  *   videoURL;

// for image or video challenge object
@property (nonatomic, assign) NSInteger challengeId;

@end

